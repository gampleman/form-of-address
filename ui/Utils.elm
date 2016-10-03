module Utils exposing (..)


last : List a -> Maybe a
last =
    List.reverse >> List.head


find : (a -> Bool) -> List a -> Maybe a
find f l =
    List.filter f l |> List.head
