module UtilsTests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (..)
import Utils


all : Test
all =
    describe "Utils"
        [ fuzz2 (list int) int "last" <|
            \l i ->
                Utils.last (l ++ [ i ])
                    |> Expect.equal (Just i)
        , fuzz (list int) "find" <|
            \l ->
                Utils.find (\_ -> True) l
                    |> Expect.equal (List.head l)
        ]
