newoption
{
	trigger = "graphics",
	value = "OPENGL_VERSION",
	description = "version of OpenGL to build raylib against",
	allowed = {
		{ "opengl11", "OpenGL 1.1"},
		{ "opengl21", "OpenGL 2.1"},
		{ "opengl33", "OpenGL 3.3"},
		{ "opengl43", "OpenGL 4.3"}
	},
	default = "opengl33"
}

function string.starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end

function link_to(lib)
	links (lib)
	includedirs ("../"..lib.."/include", "../"..lib.."/" )
end

function download_progress(total, current)
	local ratio = current / total;
	ratio = math.min(math.max(ratio, 0), 1);
	local percent = math.floor(ratio * 100);
	print("Download progress (" .. percent .. "%/100%)")
end

function check_raylib()
	if(os.isdir("raylib") == false and os.isdir("raylib-master") == false) then
		if(not os.isfile("raylib-master.zip")) then
			print("Raylib not found, downloading from github")
			local result_str, response_code = http.download("https://github.com/raysan5/raylib/archive/refs/heads/master.zip", "raylib-master.zip", {
				progress = download_progress,
				headers = { "From: Premake", "Referer: Premake" }
			})
		end
		print("Unzipping to " ..  os.getcwd())
		zip.extract("raylib-master.zip", os.getcwd())
		os.remove("raylib-master.zip")
	end
end

function check_imgui()
	if(os.isdir("imgui") == false and os.isdir("imgui-master") == false) then
		if(not os.isfile("imgui-master.zip")) then
			print("imgui not found, downloading from github")
			local result_str, response_code = http.download("https://github.com/ocornut/imgui/archive/refs/heads/master.zip", "imgui-master.zip", {
				progress = download_progress,
				headers = { "From: Premake", "Referer: Premake" }
			})
		end
		print("Unzipping to " ..  os.getcwd())
		zip.extract("imgui-master.zip", os.getcwd())
		os.remove("imgui-master.zip")
	end
end

workspaceName = path.getbasename(os.getcwd())

if (string.lower(workspaceName) == "raylib" or string.lower(workspaceName) == "rlimgui") then
    print("raylib and rlimgui are reserved name. Name your project directory something else.")
    -- Project generation will succeed, but compilation will definitely fail, so just abort here.
    os.exit()
end

workspace (workspaceName)
	configurations { "Debug", "Release" }
	platforms { "x64" }
	defaultplatform "x64"

	cdialect "C99"
	cppdialect "C++11"
	
	filter "configurations:Debug"
		defines { "DEBUG" }
		symbols "On"
		
	filter "configurations:Release"
		defines { "NDEBUG" }
		optimize "On"	
		
	filter { "platforms:x64" }
		architecture "x86_64"
	
	-- Windows
	filter "system:windows"
		cppdialect "C++17"
		staticruntime "On"
		systemversion "latest"
	filter {}

	check_raylib()
	check_imgui()

	include ("raylib_premake5.lua")
	
outputdir = "%{cfg.buildcfg}-%{cfg.system}-%{cfg.architecture}"

project "rlImGui"
	kind "StaticLib"
	language "C++"
	location "rlImGui"

	targetdir "bin/%{outputdir}/%{prj.name}"
	objdir "bin-int/%{outputdir}/%{prj.name}"
	
	include_raylib()
	includedirs { "rlImGui", "imgui", "imgui-master"}
	vpaths 
	{
		["Header Files"] = { "%{prj.name}/include/*.h"},
		["Source Files"] = {"%{prj.name}/src/*.cpp"},
		["ImGui Files"] = { "imgui/*.h","imgui/*.cpp", "imgui-master/*.h","imgui-master/*.cpp" },
	}
	files {
		"imgui-master/*.h",
		"imgui-master/*.cpp",
		"imgui/*.h",
		"imgui/*.cpp",
		"%{prj.name}/src/*.cpp",
		"%{prj.name}/include/*.h",
		"%{prj.name}/include/extras/**.h"
	}

	defines {"IMGUI_DISABLE_OBSOLETE_FUNCTIONS","IMGUI_DISABLE_OBSOLETE_KEYIO"}

project "Game"
	kind "ConsoleApp"
	language "C++"
	location "Game"

	targetdir "bin/%{outputdir}/%{prj.name}"
	objdir "bin-int/%{outputdir}/%{prj.name}"

	filter "configurations:Release"
		kind "WindowedApp"
		entrypoint "mainCRTStartup"
	filter {}
	
	vpaths 
	{
		["Header Files"] = { "**.hpp", "**.h"},
		["Source Files"] = {"**.cpp", "**.c"},
	}

	files {
		"%{prj.name}/include/**.hpp",
		"%{prj.name}/include/**.h",
		"%{prj.name}/src/**.cpp",
		"%{prj.name}/src/**.c",
	}

	link_raylib()
	links {"rlImGui"}
	includedirs {"./", "imgui", "imgui-master", "%{prj.name}/src", "%{prj.name}/include" }

-- This is a hack to get the ShowAllFiles property to show up in the project file.
require('vstudio')

premake.override(premake.vstudio.vc2010.elements, "project", function(base, prj)
	local calls = base(prj)
	table.insert(calls, function(prj)
		_p(1,'<PropertyGroup Label="MySettings">')
		_p(2,'<ShowAllFiles>true</ShowAllFiles>')
		_p(1,'</PropertyGroup>')
	end)
	return calls
end)
