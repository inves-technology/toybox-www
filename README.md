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

```sh
make up
# wait for container to start, and to show the docker whale prompt
make env=dev deploy
make env=prod deploy
```

TODO: Much the same at the others - let's get the standard stuff live first

## TO DO

- Navbar won't stay open
- TB symbol spacing on mobile
- Add a yellow overlay when you mouse over a fellow (this is hard, forget it)
- Add Google Analytics
- Link form submissions on Zapier
- Masthead image not viewable on mobile
- Add smooth scrolling
- Hook up Continuous Deployment again
- Re-look into a package manager. ParcelJS didn't work out very well.