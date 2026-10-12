obs=obslua
local elapsed=-1
local running=false
local travel_direction=1
local scene_name="PW White Teleport"
local filter_name="White Ranger Teleport"
local info={}
local instances={}
info.id="pw_white_teleport_filter"
info.type=obs.OBS_SOURCE_TYPE_FILTER
info.output_flags=obs.OBS_SOURCE_VIDEO
info.get_name=function() return "White Ranger Teleport" end

local function start_teleport()
 local current=obs.obs_frontend_get_current_scene()
 local name=current and obs.obs_source_get_name(current) or ""
 if current then obs.obs_source_release(current) end
 if name~=scene_name then
  print("Select the configured teleport scene before triggering the effect.")
  return false
 end
 elapsed=0
 travel_direction=1
 running=true
 return true
end

local function arrive()
 local current=obs.obs_frontend_get_current_scene()
 local name=current and obs.obs_source_get_name(current) or ""
 if current then obs.obs_source_release(current) end
 if name~=scene_name then print("Select the configured teleport scene before arriving.");return false end
 elapsed=2.60
 travel_direction=-1
 running=true
 return true
end

info.create=function(settings,source)
 local d={source=source,width=1920,height=1080,role=0,intensity=1.0,cx=0.54,cy=0.63,nonce=0,preview=-1}
 local file=io.open(script_path().."white-teleport.effect","r")
 local code=file and file:read("*a") or nil
 if file then file:close() end
 if not code then print("Teleport shader file is missing.");return nil end
 obs.obs_enter_graphics()
 d.effect=obs.gs_effect_create(code,nil,nil)
 obs.obs_leave_graphics()
 if not d.effect then print("White teleport shader failed to compile."); return nil end
 d.params={}
 for _,name in ipairs({"elapsed","role","intensity","centre_x","centre_y","pixel_x","pixel_y"}) do
  d.params[name]=obs.gs_effect_get_param_by_name(d.effect,name)
 end
 d.role=obs.obs_data_get_int(settings,"role")
 d.nonce=obs.obs_data_get_int(settings,"trigger_id")
 d.intensity=obs.obs_data_get_double(settings,"intensity")
 if d.intensity<=0 then d.intensity=1 end
 d.cx=obs.obs_data_get_double(settings,"centre_x")
 d.cy=obs.obs_data_get_double(settings,"centre_y")
 if d.cx==0 then d.cx=0.54 end
 if d.cy==0 then d.cy=0.63 end
 d.preview=obs.obs_data_get_double(settings,"preview_time")
 if not obs.obs_data_has_user_value(settings,"preview_time") then d.preview=-1 end
 instances[d]=true
 return d
end
info.destroy=function(d)
 instances[d]=nil
 obs.obs_enter_graphics()
 if d.effect then obs.gs_effect_destroy(d.effect) end
 obs.obs_leave_graphics()
end
info.update=function(d,settings)
 d.role=obs.obs_data_get_int(settings,"role")
 d.intensity=obs.obs_data_get_double(settings,"intensity")
 if d.intensity<=0 then d.intensity=1 end
 d.cx=obs.obs_data_get_double(settings,"centre_x")
 d.cy=obs.obs_data_get_double(settings,"centre_y")
 if d.cx==0 then d.cx=0.54 end
 if d.cy==0 then d.cy=0.63 end
 d.preview=obs.obs_data_get_double(settings,"preview_time")
 if not obs.obs_data_has_user_value(settings,"preview_time") then d.preview=-1 end
 local nonce=obs.obs_data_get_int(settings,"trigger_id")
 if nonce~=d.nonce and d.role==0 then d.nonce=nonce; start_teleport() end
end
info.get_defaults=function(settings)
 obs.obs_data_set_default_double(settings,"intensity",1.0)
 obs.obs_data_set_default_double(settings,"centre_x",0.54)
 obs.obs_data_set_default_double(settings,"centre_y",0.63)
 obs.obs_data_set_default_double(settings,"preview_time",-1.0)
end
info.get_properties=function(d)
 local p=obs.obs_properties_create()
 obs.obs_properties_add_int(p,"role","Layer role: 0 = camera, 1 = room",0,1,1)
 obs.obs_properties_add_float_slider(p,"intensity","Energy strength",0.2,2.0,0.1)
 obs.obs_properties_add_float_slider(p,"centre_x","Energy centre X",0.0,1.0,0.01)
 obs.obs_properties_add_float_slider(p,"centre_y","Energy centre Y",0.0,1.0,0.01)
 obs.obs_properties_add_float(p,"preview_time","Frozen preview time (-1 = live)",-1.0,3.0,0.05)
 return p
end
info.get_width=function(d) return d.width end
info.get_height=function(d) return d.height end
info.video_render=function(d)
 local parent=obs.obs_filter_get_parent(d.source)
 if not parent or not d.effect then obs.obs_source_skip_video_filter(d.source); return end
 d.width=obs.obs_source_get_base_width(parent)
 d.height=obs.obs_source_get_base_height(parent)
 if d.width<1 or d.height<1 then obs.obs_source_skip_video_filter(d.source); return end
 if not obs.obs_source_process_filter_begin(d.source,obs.GS_RGBA,obs.OBS_NO_DIRECT_RENDERING) then return end
 obs.gs_effect_set_float(d.params.elapsed,d.preview>=0 and d.preview or elapsed)
 obs.gs_effect_set_int(d.params.role,d.role)
 obs.gs_effect_set_float(d.params.intensity,d.intensity)
 obs.gs_effect_set_float(d.params.centre_x,d.cx)
 obs.gs_effect_set_float(d.params.centre_y,d.cy)
 obs.gs_effect_set_float(d.params.pixel_x,1/d.width)
 obs.gs_effect_set_float(d.params.pixel_y,1/d.height)
 obs.obs_source_process_filter_end(d.source,d.effect,d.width,d.height)
end

function script_description()
 return "White Ranger teleport for the new PW White Teleport Stage. Reuses your live AI camera cutout and game sources. GPU scribbles, glow, stretch, launch and reveal share one video-clock timeline. Existing sources and Stages are not configured by this script."
end
function script_tick(seconds)
 if running then
  elapsed=elapsed+seconds*travel_direction
  if travel_direction>0 and elapsed>=2.7 then elapsed=2.7; running=false end
  if travel_direction<0 and elapsed<=0 then elapsed=-1; running=false end
 end
end
function script_properties()
 local p=obs.obs_properties_create()
 obs.obs_properties_add_text(p,"scene_name","Dedicated teleport scene",obs.OBS_TEXT_DEFAULT)
 obs.obs_properties_add_button(p,"test","Test teleport",function() return start_teleport() end)
 obs.obs_properties_add_button(p,"arrive","Test teleport arrival",function() return arrive() end)
 obs.obs_properties_add_button(p,"reset","Reset to command centre",function() elapsed=-1; running=false; return true end)
 return p
end
function script_defaults(settings) obs.obs_data_set_default_string(settings,"scene_name","PW White Teleport") end
function script_update(settings) local name=obs.obs_data_get_string(settings,"scene_name"); if name~="" then scene_name=name end end
function script_load(settings)
 script_update(settings)
 obs.obs_register_source(info)
 obs.obs_hotkey_register_frontend("pw_white_teleport","White Ranger · Teleport into game",function(pressed) if pressed then start_teleport() end end)
 obs.obs_hotkey_register_frontend("pw_white_teleport_in","White Ranger · Teleport arrival",function(pressed) if pressed then arrive() end end)
 obs.obs_hotkey_register_frontend("pw_white_teleport_hide","White Ranger · Hide teleport actor",function(pressed) if pressed then elapsed=2.7;running=false end end)
 obs.obs_hotkey_register_frontend("pw_white_teleport_reset","White Ranger · Reset teleport",function(pressed) if pressed then elapsed=-1;running=false end end)
end
function script_unload() running=false;elapsed=-1 end
