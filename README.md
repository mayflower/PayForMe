# PayForMe
iOS client for Cospend on Nextcloud & iHateMoney.org
Download from the [Apple App Store](https://apps.apple.com/us/app/payforme/id1500428306?l=de&ls=1)

Open beta with new features: https://testflight.apple.com/join/o6XAnU9g

Using SwiftUI and Combine.
Inspired by Moneybuster (https://gitlab.com/eneiluj/moneybuster).

We are currently in a kind of "open beta" v1.0 All basic functionality should work, but we are not completely stable with everthing. If you find something, please create an issue or write a mail to hustenbonbon@posteo.de!
Contributions of all kind are welcome, please get in touch with us!

# Screenshots

<img src="/screenshots/lightmode/en-US/iPhone%2011-Bill%20List_framed.png?raw=true" width="200"/> <img src="/screenshots/lightmode/en-US/iPhone%2011-Balance%20List_framed.png?raw=true" width="200"/> <img src="/screenshots/lightmode/en-US/iPhone%2011-Known%20Projects_framed.png?raw=true" width="200"/> <img src="/screenshots/lightmode/en-US/iPhone%2011-Add%20Bill_framed.png?raw=true" width="200"/>
<img src="/screenshots/darkmode/en-US/iPhone%2011-Bill%20List_framed.png?raw=true" width="200"/> <img src="/screenshots/darkmode/en-US/iPhone%2011-Balance%20List_framed.png?raw=true" width="200"/> <img src="/screenshots/darkmode/en-US/iPhone%2011-Known%20Projects_framed.png?raw=true" width="200"/> <img src="/screenshots/darkmode/en-US/iPhone%2011-Add%20Bill_framed.png?raw=true" width="200"/>

## Features
* Show listed bills
* Create new bills
* Balance of project members
* Handling several projects
* Colorcodes to differentiate users
* Update bills
* Delete bills
* Clearing debt of single members
* ~Creating new projects on iHateMoney~
* Adding new members to a project


# How to contribute Localization

If you want to localize PayForMe into your language you are very welcome! Here is a short guide how, if you localized another iOS app you should find it familiar.

## MacOS way

If you are using MacOS, there is an awesome helper app called [LocalizationEditor](https://github.com/igorkulman/iOSLocalizationEditor).

To add a new localization, fork the project on github, download it, open it in XCode and then navigate to the Project/Info settings, and add a new localization file there. It is recommended, but not necessary to use LocalizationHelper then to easily translate all strings. Afterwards, commit and push you changes and open a pull request to the main repository.

