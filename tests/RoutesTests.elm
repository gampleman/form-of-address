module RoutesTests exposing (..)

import Test exposing (..)
import Expect
import Routes
import Model exposing (..)
import RequestState exposing (RequestState(..))
import RouteUrl
import Controller exposing (Msg(..))


sampleModel current =
    { organizations = Pristine
    , current = current
    , error = Nothing
    }


makeLocation href =
    { href = href
    , host = ""
    , hostname = ""
    , protocol = ""
    , origin = ""
    , port_ = ""
    , pathname = ""
    , search = ""
    , hash = ""
    , username = ""
    , password = ""
    }


all : Test
all =
    describe "Routes"
        [ describe "deltaToUrl"
            [ test "Welcome being the same" <|
                \() ->
                    Routes.deltaToUrl (sampleModel Welcome) (sampleModel Welcome)
                        |> Expect.equal Nothing
            , test "Welcome not being the same" <|
                \() ->
                    Routes.deltaToUrl (sampleModel (OrganizationDetail 1)) (sampleModel Welcome)
                        |> Expect.equal (Just <| RouteUrl.UrlChange RouteUrl.NewEntry "/")
            , test "OrganizationDetail being the same" <|
                \() ->
                    Routes.deltaToUrl (sampleModel (OrganizationDetail 1)) (sampleModel (OrganizationDetail 1))
                        |> Expect.equal Nothing
            , test "OrganizationDetail not being the same" <|
                \() ->
                    Routes.deltaToUrl (sampleModel (OrganizationDetail 4)) (sampleModel (OrganizationDetail 1))
                        |> Expect.equal (Just <| RouteUrl.UrlChange RouteUrl.NewEntry "/organizations/1")
            , test "NewOrganization being almost the same" <|
                \() ->
                    Routes.deltaToUrl (sampleModel (NewOrganization blankOrg)) (sampleModel (NewOrganization { blankOrg | name = "hello" }))
                        |> Expect.equal Nothing
            , test "NewOrganization not being the same" <|
                \() ->
                    Routes.deltaToUrl (sampleModel (OrganizationDetail 4)) (sampleModel (NewOrganization blankOrg))
                        |> Expect.equal (Just <| RouteUrl.UrlChange RouteUrl.NewEntry "/organizations/new")
            , test "PersonDetail being the same" <|
                \() ->
                    Routes.deltaToUrl (sampleModel (PersonDetail 1 2)) (sampleModel (PersonDetail 1 2))
                        |> Expect.equal Nothing
            , test "PersonDetail not being the same" <|
                \() ->
                    Routes.deltaToUrl (sampleModel (PersonDetail 4 54)) (sampleModel (PersonDetail 1 4))
                        |> Expect.equal (Just <| RouteUrl.UrlChange RouteUrl.NewEntry "/organizations/1/people/4")
            , test "NewPerson being almost the same" <|
                \() ->
                    Routes.deltaToUrl (sampleModel (NewPerson 4 blankPerson)) (sampleModel (NewPerson 4 { blankPerson | name = "hello" }))
                        |> Expect.equal Nothing
            , test "NewPerson not being the same" <|
                \() ->
                    Routes.deltaToUrl (sampleModel (OrganizationDetail 4)) (sampleModel (NewPerson 4 blankPerson))
                        |> Expect.equal (Just <| RouteUrl.UrlChange RouteUrl.NewEntry "/organizations/4/people/new")
            ]
        , describe "locationToMessages"
            [ test "/" <|
                \() ->
                    makeLocation "/"
                        |> Routes.locationToMessages
                        |> Expect.equal [ GoTo Welcome ]
            , test "/organizations/new" <|
                \() ->
                    makeLocation "/organizations/new"
                        |> Routes.locationToMessages
                        |> Expect.equal [ GoTo (NewOrganization blankOrg) ]
            , test "/organizations/4" <|
                \() ->
                    makeLocation "/organizations/4"
                        |> Routes.locationToMessages
                        |> Expect.equal [ GoTo (OrganizationDetail 4) ]
            , test "/organizations/4/people/new" <|
                \() ->
                    makeLocation "/organizations/4/people/new"
                        |> Routes.locationToMessages
                        |> Expect.equal [ GoTo (NewPerson 4 blankPerson) ]
            , test "/organizations/4/people/54" <|
                \() ->
                    makeLocation "/organizations/4/people/54"
                        |> Routes.locationToMessages
                        |> Expect.equal [ GoTo (PersonDetail 4 54) ]
            ]
        ]
