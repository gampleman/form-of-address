module RequestState exposing (..)

import Http
import Html exposing (Html, text)


type RequestState a
    = Success a
    | Pristine
    | Error Http.Error
    | Loading


map : (a -> b) -> RequestState a -> RequestState b
map fn val =
    case val of
        Success sm ->
            Success <| fn sm

        Pristine ->
            Pristine

        Error e ->
            Error e

        Loading ->
            Loading


loading : RequestState a -> (a -> Html msg) -> Html msg
loading req viewFn =
    case req of
        Pristine ->
            text ""

        Loading ->
            text "Loading..."

        Error e ->
            text <| "Something went wrong: " ++ (toString e)

        Success val ->
            viewFn val
