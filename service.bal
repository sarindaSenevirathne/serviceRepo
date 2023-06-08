import ballerina/http;
import ballerina/log;

type Album readonly & record {|
    string title;
    string artist;
|};

// Represents the subtype of http:Conflict status code record.
type AlbumConflict record {|
    *http:InternalServerError;
    json body;
|};

table<Album> key(title) albums = table [
    {title: "Blue Train", artist: "John Coltrane"},
    {title: "Jeru", artist: "Gerry Mulligan"}
];

service / on new http:Listener(9090) {

    // The resource returns the `409 Conflict` status code as the error response status code using the built-in `StatusCodeResponse`.
    resource function post albums(@http:Payload json pay) returns json|AlbumConflict {

        AlbumConflict payload = {body: pay};
        log:printInfo(payload.toString());
        return payload;
    }
}
