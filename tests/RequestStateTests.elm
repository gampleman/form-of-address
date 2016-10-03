module RequestStateTests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (..)
import RequestState exposing (RequestState(..))
import Http


all : Test
all =
    describe "RequestState.map"
        [ test "success" <|
            \() ->
                Success 4
                    |> RequestState.map (\a -> a + 2)
                    |> Expect.equal (Success 6)
        , test "loading" <|
            \() ->
                Loading
                    |> RequestState.map (\a -> a + 2)
                    |> Expect.equal (Loading)
        , test "pristine" <|
            \() ->
                Pristine
                    |> RequestState.map (\a -> a + 2)
                    |> Expect.equal (Pristine)
        , test "error" <|
            \() ->
                Error Http.NetworkError
                    |> RequestState.map (\a -> a + 2)
                    |> Expect.equal (Error Http.NetworkError)
        ]
