module Model exposing (..)

import RequestState exposing (RequestState)


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


type Page
    = Welcome
    | OrganizationDetail Int
    | NewOrganization Organization
    | PersonDetail Int Int
    | NewPerson Int Person


type alias Model =
    { organizations : RequestState (List Organization)
    , current : Page
    , error : Maybe String
    }


blankOrg : Organization
blankOrg =
    { id = Nothing, name = "", email = Nothing, phone = Nothing, address = Nothing, people = [] }


blankPerson : Person
blankPerson =
    { id = Nothing, name = "", email = Nothing, phone = Nothing, address = Nothing }
