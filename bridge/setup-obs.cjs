const {connect}=require('./obs-client.cjs');
async function main(){let camera=process.argv[2],alerts=process.argv[3];if(!camera){const prompt=require('node:readline/promises').createInterface({input:process.stdin,output:process.stdout});try{camera=(await prompt.question('Existing background-removed camera scene/source name: ')).trim();alerts=(await prompt.question('Existing alert source/scene name (Enter to skip): ')).trim();}finally{prompt.close();}}if(!camera)throw Error('A camera cutout scene/source name is required.');const api=await connect({backend:process.env.ALTRON_SETUP_BACKEND==='pulse-weaver'?'pulse-weaver':'obs'});try{
 const names=['PW Teleport AI Camera','PW Teleport Actor','Altron Background','PW White Teleport'];
 const scenes=(await api.call('GetSceneList')).scenes.map(s=>s.sceneName),inputs=(await api.call('GetInputList')).inputs.map(i=>i.inputName);
 if(names.some(n=>scenes.includes(n)||inputs.includes(n)))throw Error('Dedicated Altron names already exist. Setup stops without editing them.');
 for(const n of [camera,alerts].filter(Boolean))if(!scenes.includes(n)&&!inputs.includes(n))throw Error('Source not found: '+n);
 if(names.includes(camera)||names.includes(alerts))throw Error('Choose your existing camera and alert sources');
 const video=await api.call('GetVideoSettings');if(Math.abs(video.baseWidth/video.baseHeight-16/9)>.01)throw Error('Use a 16:9 base canvas for this landscape effect; existing video settings are unchanged.');
 const kinds=await api.call('GetSourceFilterKindList');if(!kinds.sourceFilterKinds.includes('pw_white_teleport_filter'))throw Error('Load the supplied white-teleport.lua in OBS Tools > Scripts first.');
 const add=async(sceneName,sourceName)=>api.call('CreateSceneItem',{sceneName,sourceName,sceneItemEnabled:true});
 await api.call('CreateScene',{sceneName:names[0]});const cutout=await add(names[0],camera);
 await api.call('SetSceneItemTransform',{sceneName:names[0],sceneItemId:cutout.sceneItemId,sceneItemTransform:{positionX:0,positionY:0,alignment:5,boundsType:'OBS_BOUNDS_SCALE_INNER',boundsWidth:video.baseWidth,boundsHeight:video.baseHeight,scaleX:1,scaleY:1}});
 await api.call('CreateScene',{sceneName:names[1]});await add(names[1],names[0]);
 await api.call('CreateSourceFilter',{sourceName:names[1],filterName:'White Ranger Teleport',filterKind:'pw_white_teleport_filter',filterSettings:{role:0,intensity:1.3,preview_time:-1}});
 await api.call('CreateScene',{sceneName:names[3]});
 await api.call('CreateInput',{sceneName:names[3],inputName:names[2],inputKind:'browser_source',inputSettings:{url:'http://127.0.0.1:8766/mission?v=3',width:1920,height:1080,fps:30,shutdown:false},sceneItemEnabled:true});
 const room=(await api.call('GetSceneItemList',{sceneName:names[3]})).sceneItems.find(i=>i.sourceName===names[2]);await api.call('SetSceneItemTransform',{sceneName:names[3],sceneItemId:room.sceneItemId,sceneItemTransform:{positionX:0,positionY:0,alignment:5,scaleX:video.baseWidth/1920,scaleY:video.baseHeight/1080}});
 await add(names[3],names[1]);if(alerts)await add(names[3],alerts);
 console.log('Created dedicated show scene and camera helpers. Existing sources, filters and current program scene were not edited. Select OBS scene mode in Lumia, then TEST altron-show.');
 }finally{api.close();}}
main().catch(e=>{console.error(e.message);process.exitCode=1;});
