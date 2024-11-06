// Application.h
#ifndef _APP1_H
#define _APP1_H

// Includes
#include "DXF.h"	// include dxframework
#include "TextureShader.h"
#include "ShadowShader.h"
#include "DepthShader.h"

class App1 : public BaseApplication
{
public:

	App1();
	~App1();
	void init(HINSTANCE hinstance, HWND hwnd, int screenWidth, int screenHeight, Input* in, bool VSYNC, bool FULL_SCREEN);

	bool frame();

protected:
	bool render();
	void depthPass();
	void finalPass();
	void gui();

private:
	TextureShader* textureShader;
	PlaneMesh* mesh;
	CubeMesh* cubeMesh;
	SphereMesh* sphereMesh;
	SphereMesh* light1Mesh;
	SphereMesh* light2Mesh;
	OrthoMesh* orthoMesh;

	Light* light;
	Light* light2;
	AModel* model;
	ShadowShader* shadowShader;
	DepthShader* depthShader;

	ShadowMap* shadowMap;
	ShadowMap* shadowMap2;

	ID3D11ShaderResourceView* shadowMaps[2];

	float rotation;
	float lightPos[3];
	float lightDirection[3];
	float light2Pos[3];
	float light2Direction[3];
};

#endif