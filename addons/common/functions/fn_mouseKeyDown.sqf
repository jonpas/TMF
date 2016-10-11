/*
    On keyDown:
    If no unit is being dragged: (possible other actions: "CreateObject","GroupWith","SyncWith") check if units are selected?
    * Still check if mousing over a building
    * Still check if building has positions
    * Still draw the boundingbox
    * Still draw the buildingpositions
    * Still gray out occupied positions
*/
#include "\x\tmf\addons\common\script_component.hpp"
// Exit if not left mouse button
if !(0 in GVAR(mouseKeysPressed)) exitWith {};

// Select  building from mouseOvers
//TODO: Save bbox stuff setVariable on the object, monitor the changed EH?
private _building = GVAR(edenMouseObjects);
_building = _building select {!(_x in (get3DENSelected "object"))};
if (count _building == 0) exitWith {};
_building = _building select 0;
private _positions = _building buildingPos -1;

// Draw boundingbox
if (!(typeOf _building isEqualTo "") && {count (_building buildingPos -1) > 0}) then {
    private _fn_bbox = {
        params ["_pos1","_pos2"];
        private _bbx = [_pos1 select 0,_pos2 select 0];
        private _bby = [_pos1 select 1,_pos2 select 1];
        private _bbz = [_pos1 select 2,_pos2 select 2];
        private _ret = [];
        {
            private _y = _x;
            {
                private _z = _x;
                {
                    _ret pushBack (_building modelToWorldVisual [_x,_y,_z]);
                } forEach _bbx;
            } forEach _bbz;
            reverse _bbz;
        } forEach _bby;
        _ret pushBack (_ret select 0);
        _ret pushBack (_ret select 1);
        _ret
    };
    private _box = ((boundingBoxReal _building) call _fn_bbox);

    for "_i" from 0 to 7 step 2 do {
        drawLine3D [_box select _i,_box select (_i+2),[0,1,0,1]];
        drawLine3D [_box select (_i + 2),_box select (_i + 3),[0,1,0,1]];
        drawLine3D [_box select (_i + 3),_box select (_i + 1),[0,1,0,1]];
    };
    _positions = _building buildingPos -1;
};

// Draw positions
{
    // Check for obstruction //TODO Zsorting?
    _nearObjects = (_x nearObjects ["Static",2]) + (_x nearObjects ["ThingX",2]) + (_x nearObjects ["CAManBase",2]) + (_x nearObjects ["AllVehicles",2]) - [_building];
    _color = [];
    if (count _nearObjects > 0) then {
        _color = [0.5,0.5,0.5,1];
    } else {
        _color = [1,1,1,1];
    };
    drawIcon3D ["\a3\ui_f\data\map\Markers\Military\dot_ca.paa",_color,_x,1,1,0,str _forEachIndex,2]
} forEach _positions;