module Routes exposing (..)

import Model exposing (Model, Page(..))
import Controller exposing (Msg(..))
import RouteUrl
import RouteUrl.Builder as Builder
import Navigation exposing (Location)
import String


deltaToUrl : Model -> Model -> Maybe RouteUrl.UrlChange
deltaToUrl old new =
    case new.current of
        Welcome ->
            if old.current /= Welcome then
                Builder.fromUrl "/"
                    |> Builder.newEntry
                    |> Builder.toUrlChange
                    |> Just
            else
                Nothing

        OrganizationDetail newId ->
            case old.current of
                OrganizationDetail oldId ->
                    if oldId == newId then
                        Nothing
                    else
                        Just <| RouteUrl.UrlChange RouteUrl.NewEntry <| "/organizations/" ++ (toString newId)

                _ ->
                    Just <| RouteUrl.UrlChange RouteUrl.NewEntry <| "/organizations/" ++ (toString newId)

        NewOrganization org ->
            case old.current of
                NewOrganization _ ->
                    Nothing

                _ ->
                    Builder.fromUrl "/organizations/new"
                        |> Builder.newEntry
                        |> Builder.toUrlChange
                        |> Just

        PersonDetail orgId personId ->
            case old.current of
                PersonDetail orgId' personId' ->
                    if orgId' == orgId && personId' == personId then
                        Nothing
                    else
                        Just <| RouteUrl.UrlChange RouteUrl.NewEntry <| "/organizations/" ++ (toString orgId) ++ "/people/" ++ (toString personId)

                _ ->
                    Just <| RouteUrl.UrlChange RouteUrl.NewEntry <| "/organizations/" ++ (toString orgId) ++ "/people/" ++ (toString personId)

        NewPerson orgId person ->
            case old.current of
                NewPerson orgId' _ ->
                    if orgId' == orgId then
                        Nothing
                    else
                        Builder.fromUrl ("/organizations/" ++ (toString orgId) ++ "/people/new")
                            |> Builder.newEntry
                            |> Builder.toUrlChange
                            |> Just

                _ ->
                    Builder.fromUrl ("/organizations/" ++ (toString orgId) ++ "/people/new")
                        |> Builder.newEntry
                        |> Builder.toUrlChange
                        |> Just


locationToMessages : Location -> List Msg
locationToMessages loc =
    builderToMessages (Builder.fromUrl loc.href)


builderToMessages : Builder.Builder -> List Msg
builderToMessages builder =
    case Builder.path builder of
        [] ->
            [ GoTo Welcome ]

        [ "organizations" ] ->
            [ GoTo Welcome ]

        [ "organizations", "new" ] ->
            [ GoTo (NewOrganization Model.blankOrg) ]

        "organizations" :: id :: [ "people", "new" ] ->
            let
                resolved =
                    String.toInt id
            in
                case resolved of
                    Ok resolved ->
                        [ GoTo (NewPerson resolved Model.blankPerson) ]

                    Err s ->
                        []

        "organizations" :: id :: "people" :: personId :: [] ->
            let
                orgIdResoleved =
                    String.toInt id

                personIdResoleved =
                    String.toInt personId
            in
                case ( orgIdResoleved, personIdResoleved ) of
                    ( Ok orgIdResoleved, Ok personIdResoleved ) ->
                        Debug.log "went to" <| [ GoTo (PersonDetail orgIdResoleved personIdResoleved) ]

                    _ ->
                        []

        "organizations" :: id :: [] ->
            let
                resolved =
                    String.toInt id
            in
                case resolved of
                    Ok resolved ->
                        [ GoTo (OrganizationDetail resolved) ]

                    Err s ->
                        []

        _ ->
            []
