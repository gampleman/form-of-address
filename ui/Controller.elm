module Controller exposing (Msg(..), Field(..), init, update, findOrg, findRec, subscriptions)

import Model exposing (..)
import Api exposing (..)
import RequestState exposing (RequestState(..))
import Task
import Utils


{-| This is the main Msg type, which encompasses anything that can happen within
the app.
-}
type Msg
    = RecievedOrganizations (RequestState (List Organization))
    | GoTo Page
    | ChangeField Field String
    | Save
    | OrgCreated (RequestState Organization)
    | OrgUpdated (RequestState Organization)
    | Delete
    | Deleted Int
    | PersonCreated (RequestState Organization)
    | ClearError
    | Failure String


{-| Field is used for routing updates to the text-fields in the app
-}
type Field
    = Name
    | Email
    | Address
    | Phone


{-| First thing we do is to fetch the list of organization from the server
-}
init : ( Model, Cmd Msg )
init =
    ( { organizations = Pristine, current = Welcome, error = Nothing }, perform RecievedOrganizations fetchOrganizations )



-- UPDATE


{-| This function is the single authority for handling changes to state and effects
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RecievedOrganizations orgReq ->
            ( { model | organizations = orgReq }, Cmd.none )

        GoTo page ->
            ( { model | current = page }, Cmd.none )

        ChangeField field value ->
            case ( model.current, model.organizations ) of
                ( OrganizationDetail id, Success orgs ) ->
                    ( { model
                        | organizations =
                            Success <|
                                modifyRecords orgs
                                    id
                                    (\org ->
                                        modifyRecord org field value
                                    )
                      }
                    , Cmd.none
                    )

                ( NewOrganization org, _ ) ->
                    ( { model | current = NewOrganization (modifyRecord org field value) }, Cmd.none )

                ( PersonDetail orgId personId, Success orgs ) ->
                    ( { model
                        | organizations =
                            Success <|
                                modifyRecords orgs
                                    orgId
                                    (\org ->
                                        { org | people = modifyRecords org.people personId (\person -> modifyRecord person field value) }
                                    )
                      }
                    , Cmd.none
                    )

                ( NewPerson orgId person, Success orgs ) ->
                    ( { model | current = NewPerson orgId (modifyRecord person field value) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Save ->
            case model.current of
                NewOrganization org ->
                    ( model, perform OrgCreated (createOrganization org) )

                OrganizationDetail id ->
                    case findOrg id model of
                        Just org ->
                            ( model, perform OrgUpdated (updateOrganization org) )

                        Nothing ->
                            error model "Updating the organization failed. Please try again."

                PersonDetail orgId personId ->
                    case findOrg orgId model of
                        Just org ->
                            ( model, perform OrgUpdated (updateOrganization org) )

                        Nothing ->
                            error model "Updating the person failed. Please try again."

                NewPerson orgId person ->
                    case findOrg orgId model of
                        Just org ->
                            ( model, perform PersonCreated (updateOrganization { org | people = org.people ++ [ person ] }) )

                        Nothing ->
                            error model "Updating the person failed. Please try again."

                _ ->
                    error model "Saving failed. Please try again."

        OrgCreated (Success org) ->
            case org.id of
                Just id' ->
                    ( { model | current = OrganizationDetail id', organizations = RequestState.map (\orgs -> orgs ++ [ org ]) model.organizations }, Cmd.none )

                Nothing ->
                    error model "Creating the organization failed. Please try again."

        OrgCreated smt ->
            error model "Creating the organization failed. Please try again."

        OrgUpdated (Success org) ->
            case org.id of
                Just id' ->
                    ( { model | organizations = RequestState.map (\orgs -> modifyRecords orgs id' (\a -> org)) model.organizations }, Cmd.none )

                Nothing ->
                    error model "Updating the organization failed. Please try again."

        OrgUpdated smt ->
            error model "Updating the organization failed. Please try again."

        PersonCreated (Success org) ->
            case ( org.id, Maybe.map .id <| Utils.last org.people ) of
                ( Just id', Just (Just personId) ) ->
                    ( { model | current = PersonDetail id' personId, organizations = RequestState.map (\orgs -> modifyRecords orgs id' (\a -> org)) model.organizations }, Cmd.none )

                _ ->
                    error model "Creating a person failed. Please try again."

        PersonCreated smt ->
            error model "Creating a person failed. Please try again."

        Delete ->
            case model.current of
                OrganizationDetail id ->
                    ( { model | current = Welcome }, Task.perform (\a -> Failure "Deletion failed") Deleted (destroyOrganization id) )

                NewOrganization _ ->
                    ( { model | current = Welcome }, Cmd.none )

                NewPerson orgId _ ->
                    ( { model | current = OrganizationDetail orgId }, Cmd.none )

                PersonDetail orgId personId ->
                    let
                        org =
                            findOrg orgId model

                        org' =
                            Maybe.map (\o -> { o | people = removeRecordById personId o.people }) org

                        cmd =
                            Maybe.withDefault Cmd.none <| Maybe.map (perform OrgUpdated << updateOrganization) org'
                    in
                        ( { model
                            | current = OrganizationDetail orgId
                            , organizations = RequestState.map (\orgs -> modifyRecords orgs orgId (\org -> { org | people = removeRecordById personId org.people })) model.organizations
                          }
                        , cmd
                        )

                _ ->
                    error model "Deletion failed. Please try again."

        Deleted id ->
            ( { model | organizations = RequestState.map (removeRecordById id) model.organizations }, Cmd.none )

        ClearError ->
            ( { model | error = Nothing }, Cmd.none )

        Failure s ->
            error model s


error : Model -> String -> ( Model, Cmd Msg )
error model s =
    ( { model | error = Just s }, Cmd.none )


{-| A record can either be an organzition or a Person
-}
type alias Record a =
    { a | id : Maybe Int, address : Maybe String, email : Maybe String, name : String, phone : Maybe String }


{-| Provides a generalized way to update records
-}
modifyRecord : Record a -> Field -> String -> Record a
modifyRecord org field value =
    case field of
        Name ->
            { org | name = value }

        Email ->
            { org | email = Just value }

        Address ->
            { org | address = Just value }

        Phone ->
            { org | phone = Just value }


removeRecordById : Int -> List (Record b) -> List (Record b)
removeRecordById id =
    List.filter
        (\rec ->
            case rec.id of
                Just id' ->
                    id' /= id

                Nothing ->
                    True
        )


modifyRecords : List (Record b) -> Int -> (Record b -> Record b) -> List (Record b)
modifyRecords records id fn =
    List.map
        (\rec ->
            case rec.id of
                Just id' ->
                    if id' == id then
                        fn rec
                    else
                        rec

                Nothing ->
                    rec
        )
        records


findRec : Int -> List { a | id : Maybe Int } -> Maybe { a | id : Maybe Int }
findRec id =
    Utils.find <| ((==) (Just id)) << .id


findOrg : Int -> Model -> Maybe Organization
findOrg id model =
    case model.organizations of
        Success orgs ->
            findRec id orgs

        _ ->
            Nothing



-- SUBSCRIPTIONS


{-| These allow the app to listen for outside events, in this case there are none
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
