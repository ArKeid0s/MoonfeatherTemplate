#include "raylib.h"
#include "rlImGui/include/rlImGui.h"
#include "helloWorld.h"

int main(){
	helloWorld hello;
	hello.printHelloWorld();

	InitWindow(800, 450, "Hello World");
	SetWindowState(FLAG_VSYNC_HINT);
	rlImGuiSetup(true);

	while (!WindowShouldClose())
	{
		BeginDrawing();
		ClearBackground(RAYWHITE);
		DrawText("Hello World!", 190, 200, 20, LIGHTGRAY);

		rlImGuiBegin();
		// show ImGui Content
		bool open = true;
		ImGui::ShowDemoWindow(&open);
		rlImGuiEnd();

		DrawFPS(10,10);
		EndDrawing();
	}
	CloseWindow();
	return 0;
}
