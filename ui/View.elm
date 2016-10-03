module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Controller exposing (Msg(..), Field(..))
import Json.Decode as Decode
import RequestState


onClickNoDefault : Msg -> Attribute Msg
onClickNoDefault msg =
    onWithOptions "click" { stopPropagation = False, preventDefault = True } (Decode.succeed msg)


linkForOrgId : Maybe Int -> List (Attribute Msg) -> List (Html Msg) -> Html Msg
linkForOrgId id attrs =
    case id of
        Just resolved ->
            a ([ onClickNoDefault (GoTo (OrganizationDetail resolved)), href ("/organizations/" ++ toString resolved) ] ++ attrs)

        Nothing ->
            \_ -> text ""


linkForPerson : Maybe Int -> Maybe Int -> List (Attribute Msg) -> List (Html Msg) -> Html Msg
linkForPerson orgId personId attrs =
    case ( orgId, personId ) of
        ( Just orgId, Just personId ) ->
            a ([ onClickNoDefault (GoTo (PersonDetail orgId personId)), href ("/organizations/" ++ toString orgId ++ "/person/" ++ toString personId) ] ++ attrs)

        _ ->
            \_ -> text ""


orgItem : Organization -> Html Msg
orgItem { id, name, email, phone, address, people } =
    li []
        [ linkForOrgId id [] [ text name ]
        , ul [] <|
            List.map
                (\person ->
                    li []
                        [ linkForPerson id person.id [] [ text person.name ]
                        ]
                )
                people
        ]


navigation : Model -> Html Msg
navigation model =
    RequestState.loading model.organizations
        (\orgs ->
            div []
                [ ul [] (List.map orgItem orgs)
                , p []
                    [ a [ href "/organizations/new", onClickNoDefault (GoTo (NewOrganization blankOrg)) ] [ text "New Organization" ]
                    ]
                ]
        )


welcome : Model -> Html Msg
welcome model =
    text "Welcome to the address book"


e404 : Html Msg
e404 =
    text "The resource you were looking for has not been found."


organizationEdit : Organization -> Html Msg
organizationEdit org =
    Html.form []
        [ input [ type' "text", value org.name, placeholder "Name", onInput (ChangeField Name), onBlur Save ] []
        , input [ type' "text", value (Maybe.withDefault "" <| org.email), placeholder "Email", onInput (ChangeField Email), onBlur Save ] []
        , input [ type' "text", value (Maybe.withDefault "" <| org.phone), placeholder "Phone", onInput (ChangeField Phone), onBlur Save ] []
        , textarea [ placeholder "Address", value (Maybe.withDefault "" <| org.address), onInput (ChangeField Address), onBlur Save ] []
        , button [ onClickNoDefault (Delete) ] [ text "Delete" ]
        ]


organizationDetail : Int -> Model -> Html Msg
organizationDetail id model =
    case Controller.findOrg id model of
        Just org ->
            div []
                [ organizationEdit org
                , p []
                    [ a [ href ("/organizations/" ++ toString id ++ "/people/new"), onClickNoDefault (GoTo (NewPerson id blankPerson)) ] [ text "New Person" ]
                    ]
                ]

        Nothing ->
            e404


personDetail : Int -> Int -> Model -> Html Msg
personDetail orgId personId model =
    case Controller.findOrg orgId model of
        Just org ->
            case Controller.findRec personId org.people of
                Just person ->
                    personEdit person

                Nothing ->
                    e404

        Nothing ->
            e404


personEdit : Person -> Html Msg
personEdit person =
    Html.form []
        [ input [ type' "text", value person.name, placeholder "Name", onInput (ChangeField Name), onBlur Save ] []
        , input [ type' "text", value (Maybe.withDefault "" <| person.email), placeholder "Email", onInput (ChangeField Email), onBlur Save ] []
        , input [ type' "text", value (Maybe.withDefault "" <| person.phone), placeholder "Phone", onInput (ChangeField Phone), onBlur Save ] []
        , textarea [ placeholder "Address", value (Maybe.withDefault "" <| person.address), onInput (ChangeField Address), onBlur Save ] []
        , button [ onClickNoDefault (Delete) ] [ text "Delete" ]
        ]


renderMain : Model -> Html Msg
renderMain model =
    case model.current of
        Welcome ->
            welcome model

        OrganizationDetail id ->
            organizationDetail id model

        NewOrganization org ->
            organizationEdit org

        PersonDetail orgId personId ->
            personDetail orgId personId model

        NewPerson orgId person ->
            personEdit person


view : Model -> Html Msg
view model =
    RequestState.loading model.organizations
        (\orgs ->
            div []
                [ nav [] [ navigation model ]
                , main' [] [ renderMain model ]
                , Maybe.withDefault (text "") <| Maybe.map (\s -> div [] [ text s ]) model.error
                ]
        )
