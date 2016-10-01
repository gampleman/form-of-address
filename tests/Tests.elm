module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (..)
import Api
import Json.Decode


person : Fuzzer Api.Person
person =
    Api.Person `map` (maybe int) `andMap` string `andMap` (maybe string) `andMap` (maybe string) `andMap` (maybe string)


organizations : Fuzzer (List Api.Organization)
organizations =
    list <| Api.Organization `map` (maybe int) `andMap` string `andMap` (maybe string) `andMap` (maybe string) `andMap` (maybe string) `andMap` (list person)


all : Test
all =
    describe "encoding and decoding"
        [ fuzzWith { runs = 5 } organizations "Organizations" <|
            \orgs ->
                orgs
                    |> Api.encodeOrganizations
                    |> Json.Decode.decodeValue Api.decodeOrganizations
                    |> Expect.equal (Ok orgs)
        ]
