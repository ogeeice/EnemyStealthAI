# EnemyStealthAI
A Quick and effective Enemy AI using Godot 3.5 Nav agent update


Enemy States(IDLE,PATROL,FOLLOW,SEARCH,DEATH)


How It works
- Place Enemy as a child of Navigation mesh.
- Create a Child node under the Navigation Mesh (Spatial or Position3D)
- Create children under the node added in the Navmesh as Patrol points to visualize the enemy patrol positions.
- Point the Enemy Target To the node housing th Patrol points
