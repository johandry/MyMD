# My Movies Dashboard (MyMD)

My Movies Dashboard consists of two parts: Server and Client. The Server will collect all my movies data and store it in a database. The Client will use the this database to view, filter and query the movies information in a web page, mobile or desktop.



## Build & Development

This project was generated with [yo angularfire generator](https://github.com/firebase/generator-angularfire) version 1.0.0.

Run `grunt` for building and `grunt serve` for preview.

### Fix and Workarounds

* __Missing modules__: The following modules need to be installed:

```
npm install --save-dev jasmine-core karma phantomjs karma-jasmine karma-phantomjs-launcher grunt-karma
```

* __Fatal error: Cannot read property 'contents' of undefined__: Upgrade imagemin in module grunt-contrib-imagemin

```
cd node_modules/grunt-contrib-imagemin
npm install imagemin@4.0.0
```

* __Broken style__: Due to change in bower specs Bootstrap is not loading right. Add this to bower.json

```
  "overrides": {
    "bootstrap": {
      "main": [
        "dist/css/bootstrap.css",
        "dist/js/bootstrap.js",
        "less/bootstrap.less"
      ]
    }
  }
```

## Testing

Running `grunt test` will run the unit tests with karma.

## Source

* http://markshust.com/2014/09/18/getting-started-yeoman-angular-firebase-angularfire-part-one
* https://github.com/gruntjs/grunt-contrib-imagemin/issues/330
* https://github.com/firebase/generator-angularfire/issues/59

