By: George Kochera
Class: CS475 - Project 7A - OpenCL / OpenGL Particle System

Date: 5/21/21

# Overview

This project is the final project for CS475. It is an OpenCL / OpenGL particle system. 

Particles are released from the origin outward in all directions. Particles will bounce off any solid in the environment they encounter. They are colored
in two manners. 

- The particles y velocity dictates how red or blue it is. Blue indicates a positive y velocity, red indicates a negative y velocity. Particles between 20 and -20 will be some combined shade of each to give the appearance of particles transitioning from blue, through purple, to red as they gain negative y velocity.

- Particles that strike an object will have their green component maxed out. This effect slowly fades as time continues. This allows the viewer to see particles that have recently struck an object. This affects all particles, so blue particles will appear light blue, red particles will appear yellow, and purple particles will appear white.

# Running

Visual Studio creates an executable called `Sample.exe` in the `/debug` folder contained in the project's root directory.

# Building

Open the Visual Studio project in Visual Studio 2019 and build the project as your normally would.
