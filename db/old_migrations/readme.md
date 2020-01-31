# Old Migrations

Previously, we used the `pafs_core::install:migrations` rake task to insert the
pafs_core migrations into the front office app so that we could run the
migrations on deploy.

This causes an issue when we need to run this task multiple times as we end up
with duplicated migrations in the deployed apps.

In order to prevent this from happening, we moved to adding the migrations to
the base app via the engine initializer. This allows us to manage the
migrations from the engine without complicating the deployment process, and
keeping the process consistent across environments.
