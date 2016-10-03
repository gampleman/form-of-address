port module Main exposing (..)

import ApiTests
import ControllerTests
import RequestStateTests
import RoutesTests
import UtilsTests
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)
import Test


main : Program Never
main =
    run emit <| Test.concat [ ApiTests.all, ControllerTests.all, RequestStateTests.all, RoutesTests.all, UtilsTests.all ]


port emit : ( String, Value ) -> Cmd msg
