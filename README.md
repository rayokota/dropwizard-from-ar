This code generator is based on Project Jack:
https://github.com/bryanduxbury/jack

### Project Definition File ###

The project definition file is a YAML file that tells the generator where to find your Rails projects and how to generate code. Here's an annotated example:

    ---
    # This is the name of your Dropwizard service
    service_name: myservice
    # Here, we define each of the separate databases for which the generator should 
    # generate code. Each database is roughly equivalent to a Rails project.
    databases: 
      -
        # A unique name for this database
        db_name: Database1
        # The path to the schema.rb in your Rails project.
        schema_rb: database_1/db/schema.rb
        # The path to the app/models dir in your Rails project.
        models: database_1/app/models
      -
        db_name: Database2
        schema_rb: database_2/db/schema.rb
        models: database_2/app/models

### Running the Generator ###

Running the generator:

    bin/dropwizard-from-ar project.yml /path/for/generated/code

