-------------------------------------------
-- @author https://github.com/Kasper24
-- @copyright 2021-2022 Kasper24
-------------------------------------------
--- NOTE: contains modifications and fixes for issues that I encountered.
local awful = require("awful")
local gobject = require("gears.object")
local gtable = require("gears.table")
local gtimer = require("gears.timer")
local gmath = require("gears.math")
local gdebug = require("gears.debug")
local tonumber = tonumber
local string = string
local pairs = pairs

local audio = {}

local sink = {}
local source = {}

local sink_input = {}
local source_output = {}

local instance = nil

local DEVICES_WITH_NO_VOLUME_CONTROL = {
	["GSX 1000 Main Audio analog-output-surround71"] = "GSX 1000 Main Audio analog-output-surround71",
	["GSX 1000 Main Audio analog-chat-output"] = "GSX 1000 Main Audio analog-chat-output",
	["GSX 1000 Main Audio Pro"] = "GSX 1000 Main Audio Pro",
	["GSX 1000 Main Audio Pro 1"] = "GSX 1000 Main Audio Pro 1",
}

local function can_raise_volume(sink)
	if DEVICES_WITH_NO_VOLUME_CONTROL[sink.description] then
		return false
	end

	return true
end

function audio:set_default_sink(id)
	awful.spawn(string.format("pactl set-default-sink %d", id), false)
end

function audio:set_default_source(id)
	awful.spawn(string.format("pactl set-default-source %d", id), false)
end

function audio:get_sinks()
	return self._private.sinks
end

function audio:get_sources()
	return self._private.sources
end

function audio:get_default_sink()
	for _, sink in pairs(self:get_sinks()) do
		if sink.default then
			return sink
		end
	end
end

function audio:default_sink_toggle_mute()
	local default_sink = self:get_default_sink()
	if default_sink then
		default_sink:toggle_mute()
	else
		gdebug.print_warning("Couldn't find default sink")
	end
end

function audio:default_sink_volume_up(step)
	local default_sink = self:get_default_sink()
	if default_sink then
		default_sink:volume_up(step)
	else
		gdebug.print_warning("Couldn't find default sink")
	end
end

function audio:default_sink_volume_down(step)
	local default_sink = self:get_default_sink()
	if default_sink then
		default_sink:volume_down(step)
	else
		gdebug.print_warning("Couldn't find default sink")
	end
end

function audio:default_sink_set_volume(level)
	local default_sink = self:get_default_sink()
	if default_sink then
		default_sink:set_volume(level)
	else
		gdebug.print_warning("Couldn't find default sink")
	end
end

function audio:get_default_source()
	for _, source in pairs(self:get_sources()) do
		if source.default then
			return source
		end
	end
end

function audio:default_source_toggle_mute()
	local default_source = self:get_default_source()
	if default_source then
		default_source:toggle_mute()
	else
		gdebug.print_warning("Couldn't find default source")
	end
end

function audio:default_source_volume_up(step)
	local default_source = self:get_default_source()
	if default_source then
		default_source:volume_up(step)
	else
		gdebug.print_warning("Couldn't find default source")
	end
end

function audio:default_source_volume_down(step)
	local default_source = self:get_default_source()
	if default_source then
		default_source:volume_down(step)
	else
		gdebug.print_warning("Couldn't find default source")
	end
end

function audio:default_source_set_volume(level)
	local default_source = self:get_default_source()
	if default_source then
		default_source:set_volume(level)
	else
		gdebug.print_warning("Couldn't find default source")
	end
end

function sink:toggle_mute()
	awful.spawn(string.format("pactl set-sink-mute %d toggle", self.id), false)
end

function sink:volume_up(step)
	if not can_raise_volume(sink) then
		return
	end

	awful.spawn(string.format("pactl set-sink-volume %d +%d%%", self.id, step), false)
end

function sink:volume_down(step)
	if not can_raise_volume(sink) then
		return
	end

	awful.spawn(string.format("pactl set-sink-volume %d -%d%%", self.id, step), false)
end

function sink:set_volume(volume)
	volume = gmath.round(volume)
	awful.spawn(string.format("pactl set-sink-volume %d %d%%", self.id, volume), false)
end

function source:toggle_mute()
	awful.spawn(string.format("pactl set-source-mute %d toggle", self.id), false)
end

function source:volume_up(step)
	awful.spawn(string.format("pactl set-source-volume %d +%d%%", self.id, step), false)
end

function source:volume_down(step)
	awful.spawn(string.format("pactl set-source-volume %d -%d%%", self.id, step), false)
end

function source:set_volume(volume)
	volume = gmath.round(volume)
	awful.spawn(string.format("pactl set-source-volume %d %d%%", self.id, volume), false)
end

function sink_input:toggle_mute()
	awful.spawn(string.format("pactl set-sink-input-mute %d toggle", self.id), false)
end

function sink_input:set_volume(volume)
	volume = gmath.round(volume)
	awful.spawn(string.format("pactl set-sink-input-volume %d %d%%", self.id, volume), false)
end

function source_output:toggle_mute()
	awful.spawn(string.format("pactl set-source-output-mute %d toggle", self.id), false)
end

function source_output:set_volume(volume)
	volume = gmath.round(volume)
	awful.spawn(string.format("pactl set-source-output-volume %d %d%%", self.id, volume), false)
end

local function on_default_device_changed(self)
	awful.spawn.easy_async_with_shell([[pactl info | grep "Default Sink:\|Default Source:"]], function(stdout)
		for line in stdout:gmatch("[^\r\n]+") do
			local default_device_name = line:match(": (.*)")
			local type = line:match("Default Sink") and "sinks" or "sources"
			for _, device in pairs(self._private[type]) do
				if device.name == default_device_name then
					if device.default == false then
						device.default = true
						self:emit_signal(type .. "::default", device)
					end
				else
					device.default = false
				end
				device:emit_signal("updated")
			end
		end
	end)
end

local function get_devices(self)
	awful.spawn.easy_async_with_shell(
		[[pactl list sinks | grep "Sink #\|Name:\|Description:\|Mute:\|Volume: ";
        pactl list sources | grep "Source #\|Name:\|Description:\|Mute:\|Volume:"]],
		function(stdout)
			local device = gobject({})
			for line in stdout:gmatch("[^\r\n]+") do
				if line:match("Sink") or line:match("Source") then
					device = gobject({})
					device.id = line:match("#(%d+)")
					device.type = line:match("Sink") and "sinks" or "sources"
					device.default = false
					gtable.crush(device, device.type == "sinks" and sink or source, true)
				elseif line:match("Name") then
					device.name = line:match(": (.*)")
				elseif line:match("Description") then
					device.description = line:match(": (.*)")
				elseif line:match("Mute") then
					device.mute = line:match(": (.*)") == "yes" and true or false
				elseif line:match("Volume") then
					device.volume = tonumber(line:match("(%d+)%%"))

					if self._private[device.type][device.id] == nil then
						self:emit_signal(device.type .. "::added", device)
						self._private[device.type][device.id] = device
					end
				end
			end

			on_default_device_changed(self)
		end
	)
end

local function get_applications(self)
	self.retrieving_applications = true
	awful.spawn.easy_async_with_shell(
		[[pactl list sink-inputs | grep "Sink Input #\|application.name = \|application.icon_name = \|Mute:\|Volume: ";
        pactl list source-outputs | grep "Source Output #\|application.name = \|application.icon_name = \|Mute:\|Volume: "]],
		function(stdout)
			local application = gobject({})
			local new_application = nil

			for line in stdout:gmatch("[^\r\n]+") do
				if line:match("Sink Input") or line:match("Source Output") then
					local id = line:match("#(%d+)")
					local type = line:match("Sink Input") and "sink_inputs" or "source_outputs"
					application = self._private[type][id]
					new_application = application == nil
					if new_application then
						application = gobject({})
						application.id = id
						application.type = type
						gtable.crush(
							application,
							application.type == "sink_inputs" and sink_input or source_output,
							true
						)
					end
				elseif line:match("Mute") then
					application.mute = line:match(": (.*)") == "yes" and true or false
				elseif line:match("Volume") then
					application.volume = tonumber(line:match("(%d+)%%"))
				elseif line:match("application.name") then
					application.name = line:match(" = (.*)"):gsub('"', "")
					if new_application then
						self:emit_signal(application.type .. "::added", application)
						self._private[application.type][application.id] = application
					else
						application:emit_signal("updated")
					end
				elseif line:match("application.icon_name") then
					application.icon_name = line:match(" = (.*)"):gsub('"', "")
					application:emit_signal("icon_name")
				end
			end

			self.retrieving_applications = false
		end
	)
end

local function on_object_removed(self, type, id)
	-- checking for retrieving_applications  prevents the following scenerio:
	-- A sink input was added and removed almost simultaneously
	-- get_appllications (runs an async call!) will get called for the sink input
	-- before the get_applications async call was finished, the sink input was removed calling on_object_removed
	-- get_appllications async call has finished, now it will find the old sink input which we already removed and readd it
	-- and that's because get_appllications was called when the old sink input was still present
	-- so now there's is nothing that's going to remove the old sink input, because it was already removed
	-- so with this check we won't remove any object until all get_applications calls are done
	gtimer.start_new(0.2, function()
		if self.retrieving_applications then
			return true
		end

		if self._private[type][id] then
			self:emit_signal(type .. "::removed", self._private[type][id])
			self._private[type][id] = nil
		end

		return false
	end)
end

local function on_device_updated(self, type, id)
	if self._private[type][id] == nil then
		get_devices(self)
		return
	end

	local type_no_s = type:sub(1, -2)

	awful.spawn.easy_async_with_shell(
		string.format("pactl get-%s-volume %s; pactl get-%s-mute %s", type_no_s, id, type_no_s, id),
		function(stdout)
			local was_there_any_change = false

			for line in stdout:gmatch("[^\r\n]+") do
				if line:match("Volume") then
					local volume = tonumber(line:match("(%d+)%%"))
					if volume ~= self._private[type][id].volume then
						was_there_any_change = true
					end
					self._private[type][id].volume = volume
				elseif line:match("Mute") then
					local mute = line:match(": (.*)") == "yes" and true or false
					if mute ~= self._private[type][id].mute then
						was_there_any_change = true
					end
					self._private[type][id].mute = mute
				end
			end

			if was_there_any_change == true then
				self._private[type][id]:emit_signal("updated")
				if self._private[type][id].default == true then
					self:emit_signal(type .. "::default", self._private[type][id])
				end
			end
		end
	)
end

local function new()
	local ret = gobject({})
	gtable.crush(ret, audio, true)

	ret._private = {}
	ret._private.sinks = {}
	ret._private.sources = {}
	ret._private.sink_inputs = {}
	ret._private.source_outputs = {}

   -- Here, Kasper has something where he reruns `pkill` on `pactl` every 5 seconds. This resulted in some odd
   -- behavior for me, so I opted to `pkill` it once on startup, then run it on a 5 seconds delay. I think this
   -- is what Kasper actually intended to do, may have been an oversight.
   awful.spawn.with_shell('pkill pactl')
   gtimer({
      timeout = 5,
      autostart = true,
      single_shot = true,
      call_now = false,
      callback = function()
         get_devices(ret)
         get_applications(ret)

         awful.spawn.with_line_callback([[bash -c "LC_ALL=C pactl subscribe"]], {
            stdout = function(line)
               ---------------------------------------------------------------------------------------------------------
               -- Devices
               ---------------------------------------------------------------------------------------------------------
               if line:match("Event 'new' on sink #") or line:match("Event 'new' on source #") then
                  get_devices(ret)
               elseif line:match("Event 'remove' on sink #") then
                  local id = line:match("Event 'remove' on sink #(.*)")
                  on_object_removed(ret, "sinks", id)
               elseif line:match("Event 'remove' on source #") then
                  local id = line:match("Event 'remove' on source #(.*)")
                  on_object_removed(ret, "sources", id)
               elseif line:match("Event 'change' on server") then
                  on_default_device_changed(ret)
               elseif line:match("Event 'change' on sink #") then
                  local id = line:match("Event 'change' on sink #(.*)")
                  on_device_updated(ret, "sinks", id)
               elseif line:match("Event 'change' on source #") then
                  local id = line:match("Event 'change' on source #(.*)")
                  on_device_updated(ret, "sources", id)

               ---------------------------------------------------------------------------------------------------------
               -- Applications
               ---------------------------------------------------------------------------------------------------------
               elseif
                  line:match("Event 'new' on sink%-input #") or line:match("Event 'new' on source%-input #")
               then
                  get_applications(ret)
               elseif line:match("Event 'change' on sink%-input #") then
                  get_applications(ret)
               elseif line:match("Event 'change' on source%-output #") then
                  get_applications(ret)
               elseif line:match("Event 'remove' on sink%-input #") then
                  local id = line:match("Event 'remove' on sink%-input #(.*)")
                  on_object_removed(ret, "sink_inputs", id)
               elseif line:match("Event 'remove' on source%-output #") then
                  local id = line:match("Event 'remove' on source%-output #(.*)")
                  on_object_removed(ret, "source_outputs", id)
               end
            end
         })

         return false
      end
   })

	return ret
end

if not instance then
	instance = new()
end
return instance
