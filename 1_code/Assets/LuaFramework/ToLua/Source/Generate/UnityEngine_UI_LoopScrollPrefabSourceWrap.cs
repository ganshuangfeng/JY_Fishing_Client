//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class UnityEngine_UI_LoopScrollPrefabSourceWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(UnityEngine.UI.LoopScrollPrefabSource), typeof(System.Object));
		L.RegFunction("GetObject", GetObject);
		L.RegFunction("New", _CreateUnityEngine_UI_LoopScrollPrefabSource);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("prefabName", get_prefabName, set_prefabName);
		L.RegVar("poolSize", get_poolSize, set_poolSize);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateUnityEngine_UI_LoopScrollPrefabSource(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				UnityEngine.UI.LoopScrollPrefabSource obj = new UnityEngine.UI.LoopScrollPrefabSource();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: UnityEngine.UI.LoopScrollPrefabSource.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetObject(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			UnityEngine.UI.LoopScrollPrefabSource obj = (UnityEngine.UI.LoopScrollPrefabSource)ToLua.CheckObject<UnityEngine.UI.LoopScrollPrefabSource>(L, 1);
			UnityEngine.GameObject o = obj.GetObject();
			ToLua.PushSealed(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_prefabName(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.LoopScrollPrefabSource obj = (UnityEngine.UI.LoopScrollPrefabSource)o;
			string ret = obj.prefabName;
			LuaDLL.lua_pushstring(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index prefabName on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_poolSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.LoopScrollPrefabSource obj = (UnityEngine.UI.LoopScrollPrefabSource)o;
			int ret = obj.poolSize;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index poolSize on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_prefabName(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.LoopScrollPrefabSource obj = (UnityEngine.UI.LoopScrollPrefabSource)o;
			string arg0 = ToLua.CheckString(L, 2);
			obj.prefabName = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index prefabName on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_poolSize(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			UnityEngine.UI.LoopScrollPrefabSource obj = (UnityEngine.UI.LoopScrollPrefabSource)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.poolSize = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index poolSize on a nil value");
		}
	}
}

