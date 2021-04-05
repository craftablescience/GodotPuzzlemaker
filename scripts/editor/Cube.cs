
using System;
using Godot;
using Dictionary = Godot.Collections.Dictionary;
using Array = Godot.Collections.Array;


public class Cube : Spatial
{

	public MeshInstance XP;
	public MeshInstance XM;
	public MeshInstance YP;
	public MeshInstance YM;
	public MeshInstance ZP;
	public MeshInstance ZM;

	public Dictionary Planes;
	
	
	enum FACESelectionMode {
		NONE,
		CLICK,
		DRAG
	}
	
	
	public void __Init(Vector3 pos, String type, int id)
	{  
		XP = GetNode<MeshInstance>("XP");
		XM = GetNode<MeshInstance>("XM");
		YP = GetNode<MeshInstance>("YP");
		YM = GetNode<MeshInstance>("YM");
		ZP = GetNode<MeshInstance>("ZP");
		ZM = GetNode<MeshInstance>("ZM");
		
		Planes = new Dictionary(){
			Globals.PLANEID.XP: new Dictionary(){
				{"node", self.XP},
				{"texture", null},
				{"highlighted", false},
				{"disabled", false
			}},
			Globals.PLANEID.XM: new Dictionary(){
				{"node", self.XM},
				{"texture", null},
				{"highlighted", false},
				{"disabled", false
			}},
			Globals.PLANEID.YP: new Dictionary(){
				{"node", self.YP},
				{"texture", null},
				{"highlighted", false},
				{"disabled", false
			}},
			Globals.PLANEID.YM: new Dictionary(){
				{"node", self.YM},
				{"texture", null},
				{"highlighted", false},
				{"disabled", false
			}},
			Globals.PLANEID.ZP: new Dictionary(){
				{"node", self.ZP},
				{"texture", null},
				{"highlighted", false},
				{"disabled", false
			}},
			Globals.PLANEID.ZM: new Dictionary(){
				{"node", self.ZM},
				{"texture", null},
				{"highlighted", false},
				{"disabled", false
			}}
		};
		SetTypeAll(type);
		SetPositionGrid(pos);
		SetId(id);
	
	}
	
	public int GetId()
	{
		return Int32.Parse(Name);
	}
	
	public void SetId(int cubeID)
	{  
		Name = GD.Str(cubeID);
	
	}
	
	public bool GetDisabled(int plane)
	{  
		return Planes[plane]["disabled"];
	}
	
	public void SetDisabled(int plane, bool disabled)
	{  
		Planes[plane]["disabled"] = disabled;
		if(disabled)
		{
			Planes[plane]["node"].Hide();
		}
		else
		{
			Planes[plane]["node"].Show();
		}
	}
	
	public MeshInstance GetPlane(int planeid)
	{  
		switch(planeid)
		{
			case Globals.PLANEID.XP:
				return XP;
			case Globals.PLANEID.XM:
				return XM;
			case Globals.PLANEID.YP:
				return YP;
			case Globals.PLANEID.YM:
				return YM;
			case Globals.PLANEID.ZP:
				return ZP;
			case Globals.PLANEID.ZM:
				return ZM;
			default:
				return null;
		}
	}
	
	public void SetData(Dictionary planes)
	{
		foreach(var i in GD.Range(6))
		{
			SetType(i, Planes[i]["texture"]);
			SetDisabled(i, Planes[i]["disabled"]);
	
		}
	}
	
	public Dictionary GetData()
	{  
		return Planes;
	}
	
	public void SetTypeAll(String type)
	{  
		foreach(var i in Globals.PLANEID.Values())
		{
			SetType(i, type);
		}
	}
	
	public void SetType(int plane, String type)
	{  
		Planes[plane]["node"].material_override.albedo_texture = PackLoader.textureNode.GetTexture(type);
		Planes[plane]["texture"] = type;
	}
	
	public String GetType(int plane)
	{  
		return Planes[plane]["texture"];
	}
	
	public void SetPositionGrid(Vector3 pos)
	{
		Transform.origin.x = pos.x * 10;
		Transform.origin.y = pos.y * 10;
		Transform.origin.z = pos.z * 10;
	}
	
	public Vector3 GetPositionGrid()
	{  
		return new Vector3( self.transform.origin.x / 10,
						self.transform.origin.y / 10,
						self.transform.origin.z / 10 );
	
	}
	
	public void SetFaceHighlight(int plane, bool highlighted)
	{  
		if(highlighted)
		{
			self.planes[plane]["node"].material_override.albedo_color = Color.cadetblue;
		}
		else
		{
			self.planes[plane]["node"].material_override.albedo_color = Color.white;
		}
		self.planes[plane]["highlighted"] = highlighted;
	
	}
	
	public void SetAllFaceHighlight(bool highlighted)
	{  
		foreach(var i in GD.Range(6))
		{
			self.SetFaceHighlight(i, highlighted);
	
		}
	}
	
	public bool GetFaceHighlight(int plane)
	{  
		return self.planes[plane]["highlighted"];
	
	}
	
	public int _SelectHelper(InputEvent event)
	{  
		if(event is InputEventMouseButton && ((event.button_index == BUTTONLeft || event.button_index == BUTTONRight) && event.pressed == true))
		{
			return FACESelectionMode.CLICK;
		}
		else if(event is InputEventMouseMotion && (Input.IsActionPressed("left_click") || Input.IsActionPressed("right_click")))
		{
			return FACESelectionMode.DRAG;
		}
		else
		{
			return FACESelectionMode.NONE;
	
		}
	}
	
	public void _OnSelect(int plane, InputEvent event)
	{  
		int selectHelper = self._SelectHelper(event);
		case Match (selectHelper):
			case FACESelectionMode.NONE:
				return;
				break;
			case FACESelectionMode.CLICK:
				GetParent()._OnFaceSelected(self.GetId(), plane, event.button_index, false);
				break;
			case FACESelectionMode.DRAG:
				int btn
				if(Input.IsActionPressed("left_click"))
				{
					btn = BUTTONLeft;
				}
				else if(Input.IsActionPressed("right_click"))
				{
					btn = BUTTONRight;
				}
				else
				{
					return;
				}
				GetParent()._OnFaceSelected(self.GetId(), plane, btn, true);
				break;
			case _:
				System.Diagnostics.Debug.Assert(false, "Cube._on_select says how?");
	
				break;
			break;
	}
	
	public void _OnXPSelect(Node _camera, InputEvent event, Vector3 _clickPosition, Vector3 _clickNormal, int _shapeIdx)
	{  
		self._OnSelect(Globals.PLANEID.XP, event);
	
	}
	
	public void _OnXMSelect(Node _camera, InputEvent event, Vector3 _clickPosition, Vector3 _clickNormal, int _shapeIdx)
	{  
		self._OnSelect(Globals.PLANEID.XM, event);
	
	}
	
	public void _OnYPSelect(Node _camera, InputEvent event, Vector3 _clickPosition, Vector3 _clickNormal, int _shapeIdx)
	{  
		self._OnSelect(Globals.PLANEID.YP, event);
	
	}
	
	public void _OnYMSelect(Node _camera, InputEvent event, Vector3 _clickPosition, Vector3 _clickNormal, int _shapeIdx)
	{  
		self._OnSelect(Globals.PLANEID.YM, event);
	
	}
	
	public void _OnZPSelect(Node _camera, InputEvent event, Vector3 _clickPosition, Vector3 _clickNormal, int _shapeIdx)
	{  
		self._OnSelect(Globals.PLANEID.ZP, event);
	
	}
	
	public void _OnZMSelect(Node _camera, InputEvent event, Vector3 _clickPosition, Vector3 _clickNormal, int _shapeIdx)
	{  
		self._OnSelect(Globals.PLANEID.ZM, event);
	
	
	}
	
	
	
}