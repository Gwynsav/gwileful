![Welcome!](assets/banner.png)
Welcome to this humble [AwesomeWM](https://awesomewm.org/) configuration that I made off
my [modularized default rc.lua](https://github.com/Gwynsav/modular-awm-default), focused
on being clean, simple and fast to use.

> [!WARNING]
> I have very bizarre ideas and am shameless enough to actually implement them here.
Sometimes these ideas make the WM very slow or unstable, so please beware my incompetence.

## Installation

### Dependencies
- `pactl` (usually provided by `pulseaudio-utils`) for audio widgets and keybinds. This
does NOT mean that this setup only works with `pulseaudio`, you can also use `pipewire`
by using `pipewire-pulse`.
- `playerctl` (also usually `playerctl-{dev/devel}`) for music playback widgets and
keybinds (currently TODO).
- *Network Manager* for network widgets, still TODO.
- `bluez` for bluetooth widgets, still TODO.

As of right now, this is only the AwesomeWM configuration, so to install it just:
```
# Assuming ~/.config/ exists.
git clone https://github.com/Gwynsav/gwileful.git ~/.config/awesome --recursive
```
There are also some variables in the `config` directory, so make sure everything is
defined correctly.

## Gallery

![How it looks as of 10/06/2024](assets/showcase.png)

## References and Acknowledgements

Groups/projects:
- Again, my [modularized default rc.lua](https://github.com/Gwynsav/modular-awm-default).
- All projects used as submodules of this one.
- [Feather Icons](https://feathericons.com/). Actually, I've moved away from these and
made my own icons for everything here. But still, I used them in the past and as
reference making my own icons, so I think they're still worth a mention.
- [Fairfax](https://www.kreativekorp.com/software/fonts/fairfaxhd/).

Individuals:
- [Crylia](https://github.com/Crylia/crylia-theme/), used some of their code, all
instances of this have a link to the original at the top of the file.
- [rxyhn](https://github.com/rxyhn/yoru), used calendar and some ideas.
- The beautiful artwork I often display in the screenshots is by
[みすたーおさる](https://www.pixiv.net/en/users/10770935) ("Mister Monkey" in english).
