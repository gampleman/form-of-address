module ApiTests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (..)
import Api
import Json.Decode
import Model exposing (..)


person : Fuzzer Person
person =
    Person `map` (maybe int) `andMap` string `andMap` (maybe string) `andMap` (maybe string) `andMap` (maybe string)


organizations : Fuzzer (List Organization)
organizations =
    list <| Organization `map` (maybe int) `andMap` string `andMap` (maybe string) `andMap` (maybe string) `andMap` (maybe string) `andMap` (list person)


all : Test
all =
    describe "encoding and decoding"
        [ fuzzWith { runs = 1 } organizations "Organizations" <|
            \orgs ->
                orgs
                    |> Api.encodeOrganizations
                    |> Json.Decode.decodeValue Api.decodeOrganizations
                    |> Expect.equal (Ok orgs)
        ]
