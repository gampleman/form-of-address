module ControllerTests exposing (all)

import Test exposing (..)
import Expect
import Model exposing (..)
import Controller
import Json.Decode
import RequestState exposing (RequestState(..))
import Utils


sampleModel current =
    { organizations =
        Success
            [ { blankOrg | name = "Org 1", id = Just 1 }
            , { blankOrg
                | name = "Org 2"
                , id = Just 2
                , people =
                    [ { blankPerson | name = "person 1", id = Just 1 }
                    ]
              }
            ]
    , current = current
    , error = Nothing
    }


extractPerson model =
    case model.organizations of
        Success (_ :: { people } :: []) ->
            Utils.last people

        _ ->
            Nothing


all : Test
all =
    describe "Controller"
        [ describe "init"
            [ test "returns an empty model" <|
                \() ->
                    Controller.init
                        |> fst
                        |> Expect.equal { organizations = Pristine, current = Welcome, error = Nothing }
            ]
        , describe "update"
            [ test "ChangeField when current is OrganizationDetail" <|
                \() ->
                    OrganizationDetail 1
                        |> sampleModel
                        |> Controller.update (Controller.ChangeField Controller.Email "heello@dsfe.ds")
                        |> fst
                        |> .organizations
                        |> RequestState.map List.head
                        |> Expect.equal (Success <| Just <| { blankOrg | name = "Org 1", id = Just 1, email = Just "heello@dsfe.ds" })
            , test "ChangeField when current is NewOrganization" <|
                \() ->
                    NewOrganization { blankOrg | name = "Test org" }
                        |> sampleModel
                        |> Controller.update (Controller.ChangeField Controller.Name "Heello")
                        |> fst
                        |> .current
                        |> Expect.equal (NewOrganization { blankOrg | name = "Heello" })
            , test "ChangeField when current is PersonDetail" <|
                \() ->
                    PersonDetail 2 1
                        |> sampleModel
                        |> Controller.update (Controller.ChangeField Controller.Address "1 Ortho street")
                        |> fst
                        |> extractPerson
                        |> Expect.equal (Just { blankPerson | name = "person 1", id = Just 1, address = Just "1 Ortho street" })
            , test "ChangeField when current is NewPerson" <|
                \() ->
                    NewPerson 2 { blankPerson | name = "Test person" }
                        |> sampleModel
                        |> Controller.update (Controller.ChangeField Controller.Phone "4309589")
                        |> fst
                        |> .current
                        |> Expect.equal (NewPerson 2 { blankPerson | name = "Test person", phone = Just "4309589" })
            , test "Delete when current is PersonDetail" <|
                \() ->
                    PersonDetail 2 1
                        |> sampleModel
                        |> Controller.update Controller.Delete
                        |> fst
                        |> extractPerson
                        |> Expect.equal Nothing
            ]
        , describe "findRec"
            [ test "it finds an record by id" <|
                \() ->
                    Controller.findRec 3 [ { id = Just 5, name = "A" }, { id = Just 3, name = "B" }, { id = Nothing, name = "C" } ]
                        |> Expect.equal (Just { id = Just 3, name = "B" })
            ]
        , describe "findOrg"
            [ test "it finds an org by id" <|
                \() ->
                    sampleModel Welcome
                        |> Controller.findOrg 1
                        |> Expect.equal (Just { blankOrg | name = "Org 1", id = Just 1 })
            ]
        ]
