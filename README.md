# CustomMultiplayerNodes

## Description
As the current multiplayer nodes have some issues (errors, caching, etc), I made nodes that behave pretty similarly to the the current spawner and synchronizer but with some added functionality. Namely, I wanted a way to be able to spawn nodes on specific, individual peers, and a safe way to dynamically use spawner nodes. 

## Usage
Both the CustomSpawner and the CustomSynchronizer are pretty similar to their Multiplayer node counterparts, though, there are some important differences. Instead of a `spawn_function`, the  CustomSpawner uses a `instantiate_function`. It should be treated how the `spawn_function` would be used in the MultiplayerSpawner, but the name is just different to more accurately reflect what it actually does. The CustomSpawner also has `extract_data_function`, which lets the node know what properties should be packed and how. This is needed because RPCs will not serialize objects, meaning nodes and scenes. Most functions are pretty much the same.
The synchronizer is much simpler. Instead of needing a `SceneReplicationConfig` resource, the properties are simply stored in a `PackedStringArray`. Just add the names of the properties for the root node that you want to be synced, and it will synchronize every delta cycle. Currently, the CustomSpawner only syncs properties using the always replication mode. This may be changed in the future. 

Note for both nodes that the root path needs to be set to a valid node. The node path can be relative or absolute.
