# Toybox

This is the website code for Toybox, an African innovation lab. It was built using Bootstrap 4.

Made in Cape Town.

Author:
[Phantom Design](https://phantom.design)

## Getting Started

(Prereq: Docker)

```sh
make up
```

## Deploying

(Prereq: Docker, all your AWS credentials, terraform project to be applied to master, dev and prod)

Note: the Docker container will start within the src folder. You need to cd up to the root before you deploy.

```sh
make up
cd ..
make env=dev deploy
make env=prod deploy
```

TODO: Much the same at the others - let's get the standard stuff live first

## TO DO

- Add a yellow overlay when you mouse over a fellow (this is hard, forget it)
- Add Google Analytics
- When we have Fellows, replace the Member Benefits section on the home page with that.
- Link form submissions on Zapier
- Masthead image not viewable on mobile
- Add smooth scrolling
- Hook up Continuous Deployment again
- Re-look into a package manager. ParcelJS didn't work out very well.