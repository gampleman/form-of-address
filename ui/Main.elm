module Main exposing (main)

import Html exposing (..)
import Html.App as App
import Api exposing (..)
import Task


type Msg
    = RecievedOrganizations (RequestState (List Organization))


type alias Model =
    { organizations : RequestState (List Organization) }


init : ( { organizations : RequestState a }, Cmd Msg )
init =
    ( { organizations = Pristine }, Task.perform RecievedOrganizations RecievedOrganizations fetchOrganizations )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RecievedOrganizations orgReq ->
            ( { model | organizations = orgReq }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


showOrg : Organization -> Html Msg
showOrg { name, email, phone, address } =
    div []
        [ h3 [] [ text name ]
        ]


view : Model -> Html Msg
view model =
    case model.organizations of
        Error e ->
            text <| "Something went wrong: " ++ (toString e)

        Success orgs ->
            div [] <| List.map showOrg orgs

        _ ->
            text "Loading..."


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
