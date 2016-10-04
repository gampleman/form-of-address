module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Controller exposing (Msg(..), Field(..))
import Json.Decode as Decode
import RequestState
import Css exposing (..)


styles : List Mixin -> Attribute a
styles =
    asPairs >> style


onClickNoDefault : Msg -> Attribute Msg
onClickNoDefault msg =
    onWithOptions "click" { stopPropagation = False, preventDefault = True } (Decode.succeed msg)


linkForOrgId : Maybe Int -> List (Attribute Msg) -> List (Html Msg) -> Html Msg
linkForOrgId id attrs =
    case id of
        Just resolved ->
            a ([ onClickNoDefault (GoTo (OrganizationDetail resolved)), href ("/organizations/" ++ toString resolved) ] ++ attrs)

        Nothing ->
            \_ -> Html.text ""


linkForPerson : Maybe Int -> Maybe Int -> List (Attribute Msg) -> List (Html Msg) -> Html Msg
linkForPerson orgId personId attrs =
    case ( orgId, personId ) of
        ( Just orgId, Just personId ) ->
            a ([ onClickNoDefault (GoTo (PersonDetail orgId personId)), href ("/organizations/" ++ toString orgId ++ "/person/" ++ toString personId) ] ++ attrs)

        _ ->
            \_ -> Html.text ""


orgItem : Page -> Organization -> Html Msg
orgItem current { id, name, email, phone, address, people } =
    let
        isCurrent =
            case current of
                OrganizationDetail id' ->
                    Maybe.withDefault False <| Maybe.map (\i -> id' == i) id

                _ ->
                    False
    in
        li []
            [ linkForOrgId id
                [ styles
                    [ display block
                    , textDecoration none
                    , color
                        (if isCurrent then
                            rgb 255 255 255
                         else
                            rgb 83 77 87
                        )
                    , borderBottom3 (px 1) solid (rgb 83 77 87)
                    , textTransform uppercase
                    , paddingLeft (px 10)
                    , paddingTop (px 10)
                    , paddingBottom (px 10)
                    , backgroundColor
                        (if isCurrent then
                            hex "2283EF"
                         else
                            rgba 0 0 0 0
                        )
                    ]
                ]
                [ Html.text name ]
            , ul [ styles [ listStyleType none, paddingLeft (px 0) ] ] <|
                List.map
                    (\person ->
                        let
                            isCurrent =
                                case current of
                                    PersonDetail orgId' personId' ->
                                        Maybe.withDefault False <| Maybe.map2 (\i j -> orgId' == i && personId' == j) id person.id

                                    _ ->
                                        False
                        in
                            li [ styles [ marginTop (px 10) ] ]
                                [ linkForPerson id
                                    person.id
                                    [ styles
                                        [ textDecoration none
                                        , color (rgb 0 0 0)
                                        , display block
                                        , padding (px 8)
                                        , paddingLeft (px 20)
                                        , backgroundColor
                                            (if isCurrent then
                                                hex "2283EF"
                                             else
                                                rgba 0 0 0 0
                                            )
                                        ]
                                    ]
                                    [ Html.text person.name ]
                                ]
                    )
                    people
            ]


buttonStyles : List Mixin
buttonStyles =
    [ display block
    , textDecoration none
    , color (rgb 83 77 87)
    , border3 (px 1) solid (rgb 83 77 87)
    , borderRadius (px 3)
    , padding (px 10)
    , margin (px 10)
    , backgroundColor (rgb 255 255 255)
    , textAlign center
    , cursor pointer
    ]


navigation : Model -> Html Msg
navigation model =
    div []
        [ RequestState.loading model.organizations
            (\orgs ->
                div [ styles [ Css.property "height" "calc(90vh - 80px)", Css.width (px 220), overflowY auto, borderRight3 (px 1) solid (rgb 83 77 87) ] ]
                    [ ul [ styles [ listStyleType none, padding (px 0) ] ] (List.map (orgItem model.current) orgs)
                    ]
            )
        , p []
            [ a
                [ href "/organizations/new"
                , onClickNoDefault (GoTo (NewOrganization blankOrg))
                , styles
                    (buttonStyles
                        ++ [ position absolute
                           , bottom (px 10)
                           , left (px 0)
                           , Css.width (px 170)
                           ]
                    )
                ]
                [ Html.text "New Organization" ]
            ]
        ]


welcome : Model -> Html Msg
welcome model =
    h1 [ styles [ margin2 (vh 50) auto, textAlign center, Css.width (pct 100) ] ] [ Html.text "Welcome to the address book" ]


e404 : Html Msg
e404 =
    Html.text "The resource you were looking for has not been found."


tableRow id' name value' field =
    div [ styles [ Css.property "display" "table-row", padding (px 10) ] ]
        [ label
            [ for id'
            , styles
                [ Css.property "display" "table-cell"
                , Css.width (px 100)
                , textAlign right
                , verticalAlign top
                , paddingBottom (px 20)
                , paddingRight (px 15)
                ]
            ]
            [ Html.text name ]
        , input
            [ id id'
            , type' "text"
            , value value'
            , placeholder name
            , onInput (ChangeField field)
            , onBlur Save
            , styles [ Css.property "display" "table-cell", border (px 0), borderBottom3 (px 1) solid (rgb 0 0 0), Css.width (px 300) ]
            ]
            []
        ]


organizationEdit : Organization -> Html Msg
organizationEdit org =
    Html.form [ styles [ padding (px 20), paddingBottom (px 0) ] ]
        [ img [ Html.Attributes.src "/assets/Organization.svg", styles [ Css.property "float" "left", marginRight (px 20) ] ] []
        , input
            [ type' "Html.text"
            , value org.name
            , placeholder "Name"
            , onInput (ChangeField Name)
            , onBlur Save
            , styles [ border (px 0), borderBottom3 (px 1) solid (rgb 0 0 0), fontSize (px 30), Css.width (px 400) ]
            ]
            []
        , p [] [ Html.text "Organization" ]
        , div [ styles [ Css.property "display" "table", Css.property "clear" "both", margin (px 50) ] ]
            [ tableRow "email" "Email" (Maybe.withDefault "" <| org.email) Email
            , tableRow "phone" "Phone" (Maybe.withDefault "" <| org.phone) Phone
            , tableRow "address" "Address" (Maybe.withDefault "" <| org.address) Address
            ]
        , button [ onClickNoDefault (Delete), styles (buttonStyles ++ [ borderColor (rgb 200 20 20), color (rgb 200 20 20) ]) ] [ Html.text "Delete" ]
        ]


organizationDetail : Int -> Model -> Html Msg
organizationDetail id model =
    case Controller.findOrg id model of
        Just org ->
            div []
                [ organizationEdit org
                , p []
                    [ a [ href ("/organizations/" ++ toString id ++ "/people/new"), onClickNoDefault (GoTo (NewPerson id blankPerson)), styles (buttonStyles ++ [ Css.width (px 300) ]) ] [ Html.text "Add a New Person to this Organization" ]
                    ]
                ]

        Nothing ->
            e404


personDetail : Int -> Int -> Model -> Html Msg
personDetail orgId personId model =
    case Controller.findOrg orgId model of
        Just org ->
            case Controller.findRec personId org.people of
                Just person ->
                    personEdit person

                Nothing ->
                    e404

        Nothing ->
            e404


personEdit : Person -> Html Msg
personEdit person =
    Html.form [ styles [ padding (px 20) ] ]
        [ img [ Html.Attributes.src "/assets/Person.svg", styles [ Css.property "float" "left", marginRight (px 20) ] ] []
        , input
            [ type' "text"
            , value person.name
            , placeholder "Name"
            , onInput (ChangeField Name)
            , onBlur Save
            , styles [ border (px 0), borderBottom3 (px 1) solid (rgb 0 0 0), fontSize (px 30), Css.width (px 400) ]
            ]
            []
        , p [] [ Html.text "Person" ]
        , div [ styles [ Css.property "display" "table", Css.property "clear" "both", margin (px 50) ] ]
            [ tableRow "email" "Email" (Maybe.withDefault "" <| person.email) Email
            , tableRow "phone" "Phone" (Maybe.withDefault "" <| person.phone) Phone
            , tableRow "address" "Address" (Maybe.withDefault "" <| person.address) Address
            ]
        , button [ onClickNoDefault (Delete) ] [ Html.text "Delete" ]
        ]


renderMain : Model -> Html Msg
renderMain model =
    case model.current of
        Welcome ->
            welcome model

        OrganizationDetail id ->
            organizationDetail id model

        NewOrganization org ->
            organizationEdit org

        PersonDetail orgId personId ->
            personDetail orgId personId model

        NewPerson orgId person ->
            personEdit person


view : Model -> Html Msg
view model =
    div [ styles [ fontFamilies [ qt "Helvetice Neue", "Helvetica", .value sansSerif ] ] ]
        [ header
            [ styles
                [ borderBottom3 (px 1) solid (rgb 83 77 87)
                , padding2 (px 0) (px 10)
                ]
            ]
            [ h1 [ styles [ color (rgb 83 77 87), fontWeight (int 300) ] ] [ Html.text "Form of Address" ] ]
        , RequestState.loading model.organizations
            (\orgs ->
                div [ styles [ displayFlex ] ]
                    [ nav [] [ navigation model ]
                    , main' [] [ renderMain model ]
                    ]
            )
        , Maybe.withDefault (Html.text "") <| Maybe.map (\s -> div [ styles [ position absolute, color (rgb 255 0 0), top (px 50), left (vw 30) ] ] [ Html.text s ]) model.error
        ]
