module Main exposing (main)

import Controller
import View
import Routes
import RouteUrl


main : Program Never
main =
    RouteUrl.program
        { init = Controller.init
        , update = Controller.update
        , view = View.view
        , subscriptions = Controller.subscriptions
        , delta2url = Routes.deltaToUrl
        , location2messages = Routes.locationToMessages
        }
