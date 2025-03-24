#!/bin/bash
heroku run "rails runner \"ActiveRecord::SchemaMigration.where(version: '20250322054019').first_or_create!\"" -a prompty0301
heroku run "rails runner \"ActiveRecord::SchemaMigration.where(version: '20250322054028').first_or_create!\"" -a prompty0301
heroku run "rails runner \"ActiveRecord::SchemaMigration.where(version: '20250322060323').first_or_create!\"" -a prompty0301
heroku run "rails runner \"ActiveRecord::SchemaMigration.where(version: '20250324025011').first_or_create!\"" -a prompty0301
heroku run "rails runner \"ActiveRecord::SchemaMigration.where(version: '20250324025059').first_or_create!\"" -a prompty0301
heroku run "rails runner \"ActiveRecord::SchemaMigration.where(version: '20250324034502').first_or_create!\"" -a prompty0301