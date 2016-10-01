module Api exposing (..)

import Json.Encode as Encode
import Json.Decode exposing (..)
import Http
import Task exposing (Task)


type RequestState a
    = Success a
    | Pristine
    | Error Http.Error
    | Loading


type alias Person =
    { id : Maybe Int
    , name : String
    , email : Maybe String
    , phone : Maybe String
    , address : Maybe String
    }


type alias Organization =
    { id : Maybe Int
    , name : String
    , email : Maybe String
    , phone : Maybe String
    , address : Maybe String
    , people : List Person
    }


wrapRequest : Task Http.Error a -> Task (RequestState a) (RequestState a)
wrapRequest task =
    Task.onError (Task.map Success task) (Task.fail << Error)


fetchOrganizations : Task (RequestState (List Organization)) (RequestState (List Organization))
fetchOrganizations =
    wrapRequest
        (Http.fromJson decodeOrganizations
            (Http.send Http.defaultSettings
                { verb = "GET"
                , headers = [ ( "X-API-VERSION", "1.0" ) ]
                , url = "/api/organizations"
                , body = Http.empty
                }
            )
        )


(|:) : Decoder (a -> b) -> Decoder a -> Decoder b
(|:) f aDecoder =
    f `andThen` (\f' -> f' `map` aDecoder)


decodeOrganizations : Decoder (List Organization)
decodeOrganizations =
    list decodeOrganization


decodeOrganization : Decoder Organization
decodeOrganization =
    succeed Organization
        |: (maybe ("id" := int))
        |: ("name" := string)
        |: (maybe ("email" := string))
        |: (maybe ("phone" := string))
        |: (maybe ("address" := string))
        |: ("people" := list decodePerson)


decodePerson : Decoder Person
decodePerson =
    succeed Person
        |: (maybe ("id" := int))
        |: ("name" := string)
        |: (maybe ("email" := string))
        |: (maybe ("phone" := string))
        |: (maybe ("address" := string))


encodeOrganizations : List Organization -> Encode.Value
encodeOrganizations orgs =
    Encode.list <| List.map encodeOrganization orgs


encodeMaybe : (a -> Encode.Value) -> Maybe a -> Encode.Value
encodeMaybe enc v =
    Maybe.withDefault Encode.null (Maybe.map enc v)


encodeOrganization : Organization -> Encode.Value
encodeOrganization { id, name, address, phone, email, people } =
    Encode.object <|
        [ ( "id", encodeMaybe Encode.int id )
        , ( "name", Encode.string name )
        , ( "address", encodeMaybe Encode.string address )
        , ( "phone", encodeMaybe Encode.string phone )
        , ( "email", encodeMaybe Encode.string email )
        , ( "people", Encode.list <| List.map encodePerson people )
        ]


encodePerson : Person -> Encode.Value
encodePerson { id, name, address, phone, email } =
    Encode.object <|
        [ ( "id", encodeMaybe Encode.int id )
        , ( "name", Encode.string name )
        , ( "address", encodeMaybe Encode.string address )
        , ( "phone", encodeMaybe Encode.string phone )
        , ( "email", encodeMaybe Encode.string email )
        ]
