
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end
package.path = package.path .. ";src\\?.lua"
--下面这种搜索方式在打包后失去效果
--package.path = package.path .. ";.\\src\\?.lua;.\\src\\protobuf\\?.lua;.\\src\\app\\pbc\\?.lua"

--print (package.path)
cc.FileUtils:getInstance():setPopupNotify(false)

require("app.MyApp").new():run()
--local size    = cc.Director:getInstance():getVisibleSize() -- 屏幕分辨率大小
--local origin  = cc.Director:getInstance():getVisibleOrigin() -- 从画布的某个点显示
--cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(size.width, size.height, cc.ResolutionPolicy.NO_BORDER) -- NO_BORDER可以修改成上面任意一种模式
