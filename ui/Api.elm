module Api exposing (..)

import Json.Encode as Encode
import Json.Decode exposing (..)
import Http
import Task exposing (Task)
import RequestState exposing (RequestState(..))
import Model exposing (Organization, Person)


perform : (RequestState a -> msg) -> Task (RequestState a) (RequestState a) -> Cmd msg
perform tagger =
    Task.perform tagger tagger


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


createOrganization : Organization -> Task (RequestState Organization) (RequestState Organization)
createOrganization org =
    wrapRequest
        (Http.fromJson decodeOrganization
            (Http.send Http.defaultSettings
                { verb = "POST"
                , headers = [ ( "X-API-VERSION", "1.0" ) ]
                , url = "/api/organizations"
                , body = Http.string (Encode.encode 0 (encodeOrganization org))
                }
            )
        )


updateOrganization : Organization -> Task (RequestState Organization) (RequestState Organization)
updateOrganization org =
    wrapRequest
        (case org.id of
            Just id' ->
                (Http.fromJson decodeOrganization
                    (Http.send Http.defaultSettings
                        { verb = "PATCH"
                        , headers = [ ( "X-API-VERSION", "1.0" ) ]
                        , url = "/api/organizations/" ++ toString id'
                        , body = Http.string (Debug.log "updating org" <| Encode.encode 0 (encodeOrganization { org | id = Nothing }))
                        }
                    )
                )

            Nothing ->
                Task.fail (Http.UnexpectedPayload "to update an organization, it must have an ID")
        )


destroyOrganization : Int -> Task Http.RawError Int
destroyOrganization id =
    Task.map (\_ -> id) <|
        Http.send Http.defaultSettings
            { verb = "DELETE"
            , headers = [ ( "X-API-VERSION", "1.0" ) ]
            , url = "/api/organizations/" ++ toString id
            , body = Http.empty
            }


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
        List.filterMap (\( f, s ) -> Maybe.map (\a -> ( f, a )) s) <|
            [ ( "id", Maybe.map Encode.int id )
            , ( "name", Just <| Encode.string name )
            , ( "address", Maybe.map Encode.string address )
            , ( "phone", Maybe.map Encode.string phone )
            , ( "email", Maybe.map Encode.string email )
            , ( "people", Just <| Encode.list <| List.map encodePerson people )
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


blankOrg : Organization
blankOrg =
    { id = Nothing, name = "", email = Nothing, phone = Nothing, address = Nothing, people = [] }


blankPerson : Person
blankPerson =
    { id = Nothing, name = "", email = Nothing, phone = Nothing, address = Nothing }
