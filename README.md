# Altron OBS / Pulse Weaver bridge

Windows bridge and GPU teleport effect for the separately supplied Blue Command Avatar 3.1.1 Lumia plugin. The plugin and private overlay are supplied by DM; neither is hosted here.

## OBS Studio

Enable OBS WebSocket in Tools > WebSocket Server Settings. Install the Lumia plugin and save Teleport scene control = OBS scene (standard OBS). Load bridge/white-teleport.lua in OBS Tools > Scripts, keeping its .effect beside it. Use a working background-removed camera scene/source. Run bridge/Setup-OBS.cmd and enter that source and your alert source name. Run bridge/Start-Bridge.cmd and leave it open. Setup creates new show/helpers only, stopping if their names already exist. Any 16:9 base canvas is supported.

## Pulse Weaver

Enable its OBS WebSocket server and local Stage API. Install the same Lumia plugin and save Teleport scene control = Pulse Weaver Stage. Load bridge/white-teleport.lua via Studio > Tools > Scripts. Use a working background-removed camera scene/source, then run bridge/Setup-Pulse-Weaver.cmd and supply your camera cutout and alert source names. In Manage stages, create a new Stage named PW White Teleport and assign its landscape view to the newly created PW White Teleport scene. This Stage creation is manual; the setup script does not create a Stage. Run bridge/Start-Bridge.cmd and leave it open.

## Routine and customization

Install the overlay from the private link sent by DM. Create a Lumia chat command named altron-show (No Light Change), open its Actions JSON editor and paste test-show/altron-show-actions.json. It contains native actions, not a .lumia export. Save, select your own headphones in EVERY TTS action, and select the same endpoint in the plugin audio monitor. Keep TTS wait-until-finished on, use queue lane Q9 and leave Skip Queue off. Restrict the command to streamer use during setup. Click TEST on the command.

Backgrounds and Altron head: Lumia overlay > layer Configuration > Apply these looks. Camera positions: Lumia plugin > Teleport placements > SAVE. Lumi-Con: any alert > Lumia Call Command > altron-show, or the individual Blue Command Avatar actions.

Node.js 22+ is required. Only run one of OBS/Pulse Weaver at a time if both use WebSocket port 4455 or the same camera. Credentials are read locally from the recipient app's config; no credentials are included. Portable standard OBS may set ALTRON_OBS_CONFIG to its own obs-websocket/config.json path.

The core show was tested in Pulse Weaver. The full native TTS show was additionally tested in OBS 32.2.2 at 2560x1440: room, laundromat, moon, freezer, room; one program scene, alternating camera corners and headphone-driven glow. The new Pulse Weaver setup wrapper is the same helper-scene builder using the Pulse Weaver connection; Stage creation remains manual.
