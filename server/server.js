const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");

const https = require("https");

const PORT = 8081;

const app = express();

const path = require("path");

app.use(bodyParser.json());

app.use(cors());

// app.use(express.static(path.join(__dirname, "../dist/project8")));

// hw9
app.get("/current", function(req, res) {
  var lat = req.query.localLat;
  var long = req.query.localLon;
  searchOnLocal(lat, long, res);
  
});

app.get("/searchInput", function(req, finalresponse) {
  var input = req.query.input


  var geoUrl =
    "https://maps.googleapis.com/maps/api/geocode/json?address=" +
    encodeURIComponent(input) +
    "&key=AIzaSyCZXqQcZ7rM2-uuyBBJxBT0tKEUQOekKgc";

  var jsonData;
  var output;
  https.get(geoUrl, res => {
    res.setEncoding("utf8");
    let body = "";

    if (res.statusCode != 200) {
      console.log(
        "Search On Input: non-200 response status code:",
        res.statusCode
      );

      res.status(400).send("Bad Request");
      return;
    }

    res.on("data", data => {
      //   console.log("reading data");
      body += data;
    });
    res.on("end", () => {
      //   console.log("parsing data");
      body = JSON.parse(body);
      jsonData = body;
      // console.log(jsonData);

      var status = jsonData.status;

      if (status == "ZERO_RESULTS") {
        console.log("get bad request");
        res.status(200).send(jsonData);
        return;
      }

      var results = jsonData.results[0];
      var lat = results.geometry.location.lat;
      var lng = results.geometry.location.lng;

      output = [lat, lng];
      // console.log("Got lat&lon from street + city");

      console.log("ready to call forecast on input")
      var param = lat + "," + lng;
      var searchUrl =
        "https://api.forecast.io/forecast/c46134d01d13e09e11779054a37019b0/" +
        encodeURIComponent(param);

      https.get(searchUrl, response => {
        response.setEncoding("utf8");
        let body = "";
        response.on("data", data => {
          //   console.log("reading data");
          body += data;
        });
        response.on("end", () => {
          //   console.log("parsing data");
          body = JSON.parse(body);
          jsonData = body;
          console.log("Search on Input done");
          //   console.log(jsonData);
          finalresponse.status(200).send(jsonData);
        });
      });
    });
  });
  
  
});


app.get("/searchPicture", function(req, response) {
  var searchAPI = "AIzaSyBmxcEBMLXMicNN72nwCoa2lxY2lVHOtoE";
  var searchEngineID = "014154138299411005294:dbznv1bxd4v";

  var url =
    "https://www.googleapis.com/customsearch/v1?q=" +
    encodeURIComponent(req.query.place) +
    "&cx=" +
    encodeURIComponent(searchEngineID) +
    "&imgSize=huge&num=8&searchType=image&key=" +
    encodeURIComponent(searchAPI);

  // console.log(url);

  https.get(url, res => {
    res.setEncoding("utf8");
    let body = "";
    res.on("data", data => {
      //   console.log("reading data");
      body += data;
    });
    res.on("end", () => {
      //   console.log("parsing data");
      body = JSON.parse(body);
      jsonData = body;

      console.log("Search on google picture done");
      //   console.log(jsonData);
      response.status(200).send(jsonData);
    });
  });
});



////////end of hw9


app.get("/searchState", function(req, response) {
  var searchAPI = "AIzaSyBmxcEBMLXMicNN72nwCoa2lxY2lVHOtoE";
  var searchEngineID = "014154138299411005294:dbznv1bxd4v";

  var url =
    "https://www.googleapis.com/customsearch/v1?q=" +
    encodeURIComponent(req.query.stateName) +
    "%20State%20Seal&cx=" +
    encodeURIComponent(searchEngineID) +
    "&num=1&searchType=image&key=" +
    encodeURIComponent(searchAPI);

  // console.log(url);

  https.get(url, res => {
    res.setEncoding("utf8");
    let body = "";
    res.on("data", data => {
      //   console.log("reading data");
      body += data;
    });
    res.on("end", () => {
      //   console.log("parsing data");
      body = JSON.parse(body);
      jsonData = body;

      console.log("Search on state seal done");
      //   console.log(jsonData);
      response.status(200).send(jsonData);
    });
  });
});

app.get("/auto", function(req, response) {

  console.log("in auto call");
  var url =
    "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=" +
    encodeURIComponent(req.query.input) +
    "&types=(cities)&language=en&key=AIzaSyBmxcEBMLXMicNN72nwCoa2lxY2lVHOtoE";
  //   console.log(url);
  https.get(url, res => {
    res.setEncoding("utf8");
    let body = "";
    res.on("data", data => {
      //   console.log("reading data");
      body += data;
    });
    res.on("end", () => {
      //   console.log("parsing data");
      body = JSON.parse(body);
      jsonData = body;
      var output = [];

      if (jsonData["status"] == "INVALID_REQUEST") {
        console.log("invalid input");
      } else {
        var toLiterate = jsonData["predictions"];
        for (var index in toLiterate) {
          //   console.log(index);
          var row = toLiterate[index];

          var place = row["description"]
          // var format = row["structured_formatting"];
          // // console.log(item);
          // var city = format["main_text"];
          //   console.log(city);
          output.push(place);
        }
      }
      // console.log("send back auto cities");
      response.status(200).send(output);
    });
  });
});

app.get("/fav", function(req, response) {
  var city = req.query.city;
  var state = req.query.state;

  var loc = city + "," + state;
  var geoUrl =
    "https://maps.googleapis.com/maps/api/geocode/json?address=" +
    encodeURIComponent(loc) +
    "&key=AIzaSyCZXqQcZ7rM2-uuyBBJxBT0tKEUQOekKgc";

  var jsonData;
  var output;

  https.get(geoUrl, res => {
    res.setEncoding("utf8");
    let body = "";
    res.on("data", data => {
      //   console.log("reading data");
      body += data;
    });
    res.on("end", () => {
      //   console.log("parsing data");
      body = JSON.parse(body);
      jsonData = body;
      //   console.log(jsonData);

      var results = jsonData.results[0];

      var lat = results.geometry.location.lat;
      var lng = results.geometry.location.lng;

      output = [lat, lng];
      // console.log("Got lat&lon from street + city");

      var param = lat + "," + lng;
      var searchUrl =
        "https://api.forecast.io/forecast/c46134d01d13e09e11779054a37019b0/" +
        encodeURIComponent(param);

      https.get(searchUrl, res => {
        res.setEncoding("utf8");
        let body = "";
        res.on("data", data => {
          //   console.log("reading data");
          body += data;
        });
        res.on("end", () => {
          //   console.log("parsing data");
          body = JSON.parse(body);
          jsonData = body;
          console.log("Search on Input done");
          //   console.log(jsonData);
          response.status(200).send(jsonData);
        });
      });
    });
  });
});

app.get("/submit", function(req, res) {
  var street = req.query.street;
  var city = req.query.city;
  var state = req.query.state;
  var locationBox = req.query.locationBox;

  //   if location is sent here
  if (locationBox === "true") {
    var lat = req.query.localLat;
    var long = req.query.localLon;
    searchOnLocal(lat, long, res);
  } else {
    // use provided address
    searchOnInput(street, city, state, res);
  }
});


app.get("/detail", function(req, response) {
  var lat = req.query.lat;
  var long = req.query.long;
  var timeStamp = req.query.timeStamp;

  var loc = lat + "," + long + "," + timeStamp;
  var searchUrl =
    "https://api.forecast.io/forecast/c46134d01d13e09e11779054a37019b0/" +
    encodeURIComponent(loc);

  https.get(searchUrl, res => {
    res.setEncoding("utf8");
    let body = "";
    res.on("data", data => {
      //   console.log("reading data");
      body += data;
    });
    res.on("end", () => {
      //   console.log("parsing data");
      body = JSON.parse(body);
      jsonData = body;

      console.log("Search on detail done");
      //   console.log(jsonData);
      response.status(200).send(jsonData);
    });
  });
});

app.post("/", function(req, res) {
  res.send("Post part: hello from server");
});

app.listen(PORT, function(req, res) {
  console.log("Server running on localhost:" + PORT);
});


//////////////

function searchOnInput(street, city, state, response) {
  //   console.log("i am in input serach");
  var loc = street + "," + city + "," + state;
  var geoUrl =
    "https://maps.googleapis.com/maps/api/geocode/json?address=" +
    encodeURIComponent(loc) +
    "&key=AIzaSyCZXqQcZ7rM2-uuyBBJxBT0tKEUQOekKgc";

  var jsonData;
  var output;
  https.get(geoUrl, res => {
    res.setEncoding("utf8");
    let body = "";

    if (res.statusCode != 200) {
      console.log(
        "Search On Input: non-200 response status code:",
        res.statusCode
      );

      response.status(400).send("Bad Request");
      return;
    }

    res.on("data", data => {
      //   console.log("reading data");
      body += data;
    });
    res.on("end", () => {
      //   console.log("parsing data");
      body = JSON.parse(body);
      jsonData = body;
      // console.log(jsonData);

      var status = jsonData.status;

      if (status == "ZERO_RESULTS") {
        console.log("get bad request");
        response.status(200).send(jsonData);
        return;
      }

      var results = jsonData.results[0];
      var lat = results.geometry.location.lat;
      var lng = results.geometry.location.lng;

      output = [lat, lng];
      // console.log("Got lat&lon from street + city");

      var param = lat + "," + lng;
      var searchUrl =
        "https://api.forecast.io/forecast/c46134d01d13e09e11779054a37019b0/" +
        encodeURIComponent(param);

      https.get(searchUrl, res => {
        res.setEncoding("utf8");
        let body = "";
        res.on("data", data => {
          //   console.log("reading data");
          body += data;
        });
        res.on("end", () => {
          //   console.log("parsing data");
          body = JSON.parse(body);
          jsonData = body;
          console.log("Search on Input done");
          //   console.log(jsonData);
          response.status(200).send(jsonData);
        });
      });
    });
  });
}

function searchOnLocal(lat, long, response) {
  //   console.log("i am in local serach");
  var param = lat + "," + long;
  var searchUrl =
    "https://api.forecast.io/forecast/c46134d01d13e09e11779054a37019b0/" +
    encodeURIComponent(param);

  https.get(searchUrl, res => {
    res.setEncoding("utf8");
    let body = "";

    if (res.statusCode != 200) {
      console.log(
        "Search On Local: non-200 response status code:",
        res.statusCode
      );

      response.status(400).send("Bad Request");
      return;
    }

    res.on("data", data => {
      //   console.log("reading data");
      body += data;
    });
    res.on("end", () => {
      //   console.log("parsing data");
      body = JSON.parse(body);
      jsonData = body;

      console.log("Search on Local done");
      //   console.log(jsonData);
      response.status(200).send(jsonData);
    });
  });
}

//Any routes will be redirected to the angular app
// app.get("*", function(req, res) {
//   res.sendFile(path.join(__dirname, "../dist/project8/index.html"));
// });
