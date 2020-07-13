exports.config = {
    // See http://brunch.io/#documentation for docs.
    files: {
        javascripts: {
            joinTo: {
                "js/app.js": /^(js)/,
                "js/vendor.js": /^(vendor)|(deps)/
            },
            order: {
                before: [
                    "vendor/js/jquery.min.js",
                    "vendor/js/bootstrap.min.js"
                ],
                after: [
                    "js/custom.js"
                ]
            }
        },
        stylesheets: {
            joinTo: "css/app.css",
            order: {
                before: [
                    "vendor/css/bootstrap.min.css"
                ],
                after: [
                    "css/app.css",
                    "css/colors/default.css",
                    "css/custom.css"
                ]
            }
        },
        templates: {
            joinTo: "js/app.js"
        }
    },

    conventions: {
        // This option sets where we should place non-css and non-js assets in.
        // By default, we set this to "/assets/static". Files in this directory
        // will be copied to `paths.public`, which is "priv/static" by default.
        assets: /^(static)/
    },

    // Phoenix paths configuration
    paths: {
        watched: ["static", "css", "js", "vendor"],
        public: "../priv/static"
    },

    // Configure your plugins
    plugins: {
        babel: {
            // Do not use ES6 compiler in vendor code
            ignore: [/vendor/]
        },
        uglify: {
            mangle: true,
            compress: {
                global_defs: {
                    DEBUG: true
                }
            }
        }
    },

    modules: {
        autoRequire: {
            "js/app.js": ["js/app", 'js/custom']
        }
    },

    npm: {
        enabled: true
    }
};