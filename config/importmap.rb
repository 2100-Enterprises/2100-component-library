# Not preloaded, so a page that shows no dismissible component doesn't fetch these.
pin "component_library_2100", to: "component_library_2100/index.js", preload: false
pin_all_from File.expand_path("../app/javascript/component_library_2100/controllers", __dir__),
             under: "component_library_2100/controllers", preload: false
