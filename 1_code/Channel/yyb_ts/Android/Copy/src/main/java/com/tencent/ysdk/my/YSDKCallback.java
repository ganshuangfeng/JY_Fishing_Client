package com.tencent.ysdk.my;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.drawable.BitmapDrawable;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.PopupWindow;

import com.tencent.tmgp.hlttby.R;
import com.tencent.tmgp.hlttby.UnityPlayerActivity;
import com.tencent.ysdk.api.YSDKApi;
import com.tencent.ysdk.module.AntiAddiction.listener.AntiAddictListener;
import com.tencent.ysdk.module.AntiAddiction.listener.AntiRegisterWindowCloseListener;
import com.tencent.ysdk.module.AntiAddiction.model.AntiAddictRet;
import com.tencent.ysdk.module.bugly.BuglyListener;
import com.tencent.ysdk.module.pay.PayListener;
import com.tencent.ysdk.module.pay.PayRet;
import com.tencent.ysdk.module.user.PersonInfo;
import com.tencent.ysdk.module.user.UserListener;
import com.tencent.ysdk.module.user.UserLoginRet;
import com.tencent.ysdk.module.user.UserRelationRet;
import com.tencent.ysdk.module.user.WakeupRet;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

//import com.tencent.smtt.sdk.WebViewClient;
//import com.tencent.tmgp.hlttby.IShowView;

public class YSDKCallback implements UserListener, BuglyListener,PayListener , AntiAddictListener {
    public static UnityPlayerActivity mainActivity;
    // 防沉迷指令执行状态
    public static boolean mAntiAddictExecuteState = false;

    public static AntiRegisterWindowCloseListener sRegisterWindowCloseListener;
//    public static IShowView sShowView;
    public YSDKCallback(Activity activity) {
        mainActivity = (UnityPlayerActivity) activity;
    }

    public void OnLoginNotify(UserLoginRet ret) {
        YSDKController.GetInstance().OnLoginNotify(ret);

        /*Log.d("[YSDK] LoginNotify","called");
        Log.d("[YSDK] LoginNotify",ret.getAccessToken());
        Log.d("[YSDK] LoginNotify",ret.getPayToken());
        Log.d("[YSDK] LoginNotify","ret.flag" + ret.flag);
        Log.d("[YSDK] LoginNotify",ret.toString());

        switch (ret.flag) {
            case eFlag.Succ:
                YYSDKController.GetInstance().letUserLogin();
                break;
            // 游戏逻辑，对登录失败情况分别进行处理
            case eFlag.QQ_UserCancel:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "用户取消授权，请重试");
                break;
            case eFlag.QQ_LoginFail:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "QQ登录失败，请重试");
                break;
            case eFlag.QQ_NetworkErr:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "QQ登录异常，请重试");
                break;
            case eFlag.QQ_NotInstall:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "手机未安装手Q，请安装后重试");
                break;
            case eFlag.QQ_NotSupportApi:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "手机手Q版本太低，请升级后重试");
                break;
            case eFlag.WX_NotInstall:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "手机未安装微信，请安装后重试");
                break;
            case eFlag.WX_NotSupportApi:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "手机微信版本太低，请升级后重试");
                break;
            case eFlag.WX_UserCancel:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "用户取消授权，请重试");
                break;
            case eFlag.WX_UserDeny:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "用户拒绝了授权，请重试");
                break;
            case eFlag.WX_LoginFail:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "微信登录失败，请重试");
                break;
            case eFlag.Login_TokenInvalid:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "您尚未登录或者之前的登录已过期，请重试");
                break;
            case eFlag.Login_NotRegisterRealName:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "您的账号没有进行实名认证，请实名认证后重试");
                break;
            default:
                UnityPlayer.UnitySendMessage("SDK_callback", "OnWeChatError", "请等待...");
                break;
        }*/
    }

    public void OnWakeupNotify(WakeupRet ret) {
        YSDKController.GetInstance().OnWakeupNotify(ret);

        /*Log.d("[YSDK] OnWakeupNotify","called");
        Log.d("[YSDK] OnWakeupNotify","flag:" + ret.flag);
        Log.d("[YSDK] OnWakeupNotify","msg:" + ret.msg);
        Log.d("[YSDK] OnWakeupNotify","platform:" + ret.platform);

        //MainActivity.platform = ret.platform;
        // TODO GAME 游戏需要在这里增加处理异账号的逻辑
        if (eFlag.Wakeup_YSDKLogining == ret.flag) {
            // 用拉起的账号登录，登录结果在OnLoginNotify()中回调
        } else if (ret.flag == eFlag.Wakeup_NeedUserSelectAccount) {
            // 异账号时，游戏需要弹出提示框让用户选择需要登录的账号
            Log.d("[YSDK] OnWakeupNotify","diff account");
            //mainActivity.showDiffLogin();
        } else if (ret.flag == eFlag.Wakeup_NeedUserLogin) {
            // 没有有效的票据，登出游戏让用户重新登录
            Log.d("[YSDK] OnWakeupNotify","need login");
            YYSDKController.GetInstance().letUserLogout(ret.flag);
        } else {
            Log.d("[YSDK] OnWakeupNotify","logout");
            //mainActivity.letUserLogout();
        }*/
    }

    @Override
    public void OnRelationNotify(UserRelationRet relationRet) {
        String result = "";
        result = result + "flag:" + relationRet.flag + "\n";
        result = result + "msg:" + relationRet.msg + "\n";
        result = result + "platform:" + relationRet.platform + "\n";
        if (relationRet.persons != null && relationRet.persons.size() > 0) {
            PersonInfo personInfo = (PersonInfo) relationRet.persons.firstElement();
            StringBuilder builder = new StringBuilder();
            builder.append("UserInfoResponse json: \n");
            builder.append("nick_name: " + personInfo.nickName + "\n");
            builder.append("open_id: " + personInfo.openId + "\n");
            builder.append("userId: " + personInfo.userId + "\n");
            builder.append("gender: " + personInfo.gender + "\n");
            builder.append("picture_small: " + personInfo.pictureSmall + "\n");
            builder.append("picture_middle: " + personInfo.pictureMiddle + "\n");
            builder.append("picture_large: " + personInfo.pictureLarge + "\n");
            builder.append("provice: " + personInfo.province + "\n");
            builder.append("city: " + personInfo.city + "\n");
            builder.append("country: " + personInfo.country + "\n");
            result = result + builder.toString();
        } else {
            result = result + "relationRet.persons is bad";
        }
        Log.d("[YSDK] OnRelationNotify", "OnRelationNotify" + result);

        // 发送结果到结果展示界面
        //mainActivity.sendResult(result);
    }

    @Override
    public String OnCrashExtMessageNotify() {
        // 此处游戏补充crash时上报的额外信息
        Log.d("[YSDK] OnCrashNotify", String.format(Locale.CHINA, "OnCrashExtMessageNotify called"));
        Date nowTime = new Date();
        SimpleDateFormat time = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
        return "new Upload extra crashing message for bugly on " + time.format(nowTime);
    }

    @Override
    public byte[] OnCrashExtDataNotify() {
        return null;
    }

    @Override
    public void OnPayNotify(PayRet ret) {
        YSDKController.GetInstance().OnPayNotify(ret);

        /*Log.d("[YSDK] OnPayNotify",ret.toString());
        if(PayRet.RET_SUCC == ret.ret){
            UnityPlayer.UnitySendMessage("SDK_callback", "OnRecharge", "0:" + ret.payState);
            //支付流程成功
            switch (ret.payState){
                //支付成功
                case PayRet.PAYSTATE_PAYSUCC:
                    UnityPlayer.UnitySendMessage("SDK_callback", "OnRecharge", "0:0");
                    mainActivity.sendResult(
                            "用户支付成功，支付金额"+ret.realSaveNum+";" +
                                    "使用渠道："+ret.payChannel+";" +
                                    "发货状态："+ret.provideState+";" +
                                    "业务类型："+ret.extendInfo+";建议查询余额："+ret.toString());
                    break;
                //取消支付
                case PayRet.PAYSTATE_PAYCANCEL:
                    //mainActivity.sendResult("用户取消支付："+ret.toString());
                    UnityPlayer.UnitySendMessage("SDK_callback", "OnRecharge", "0");
                    break;
                //支付结果未知
                case PayRet.PAYSTATE_PAYUNKOWN:
                    //mainActivity.sendResult("用户支付结果未知，建议查询余额："+ret.toString());
                    UnityPlayer.UnitySendMessage("SDK_callback", "OnRecharge", "-1");
                    break;
                //支付失败
                case PayRet.PAYSTATE_PAYERROR:
                    //mainActivity.sendResult("支付异常"+ret.toString());
                    UnityPlayer.UnitySendMessage("SDK_callback", "OnRecharge", "-2");
                    break;
            }
        }else{
            UnityPlayer.UnitySendMessage("SDK_callback", "OnRecharge", "-1:" + ret.flag);
            switch (ret.flag){
                case eFlag.Login_TokenInvalid:
                    //mainActivity.sendResult("登录态过期，请重新登录："+ret.toString());
                    //mainActivity.letUserLogout();
                    UnityPlayer.UnitySendMessage("SDK_callback", "OnRecharge", "-101");
                    break;
                case eFlag.Pay_User_Cancle:
                    //用户取消支付
                    //mainActivity.sendResult("用户取消支付："+ret.toString());
                    UnityPlayer.UnitySendMessage("SDK_callback", "OnRecharge", "-102");
                    break;
                case eFlag.Pay_Param_Error:
                    //mainActivity.sendResult("支付失败，参数错误"+ret.toString());
                    UnityPlayer.UnitySendMessage("SDK_callback", "OnRecharge", "-103");
                    break;
                case eFlag.Error:
                default:
                    //mainActivity.sendResult("支付异常"+ret.toString());
                    UnityPlayer.UnitySendMessage("SDK_callback", "OnRecharge", "-104");
                    break;
            }
        }*/
    }

    @Override
    public void onLoginLimitNotify(AntiAddictRet ret) {
        if (AntiAddictRet.RET_SUCC == ret.ret) {
            // 防沉迷指令
            switch (ret.ruleFamily) {
                case AntiAddictRet.RULE_WORK_TIP:
                case AntiAddictRet.RULE_WORK_NO_PLAY:
                case AntiAddictRet.RULE_HOLIDAY_TIP:
                case AntiAddictRet.RULE_HOLIDAY_NO_PLAY:
                case AntiAddictRet.RULE_NIGHT_NO_PLAY:
                case AntiAddictRet.RULE_GUEST:
                default:
                    YSDKCallback.executeInstruction(ret);
                    break;
            }

        }
    }

    @Override
    public void onTimeLimitNotify(AntiAddictRet ret) {
        if (AntiAddictRet.RET_SUCC == ret.ret) {
            // 防沉迷指令
            switch (ret.ruleFamily) {
                case AntiAddictRet.RULE_WORK_TIP:
                case AntiAddictRet.RULE_WORK_NO_PLAY:
                case AntiAddictRet.RULE_HOLIDAY_TIP:
                case AntiAddictRet.RULE_HOLIDAY_NO_PLAY:
                case AntiAddictRet.RULE_NIGHT_NO_PLAY:
                case AntiAddictRet.RULE_GUEST:
                default:
                    YSDKCallback.executeInstruction(ret);
                    break;
            }
        }
    }
    public static void executeInstruction(AntiAddictRet ret) {
        final int modal = ret.modal;
        switch (ret.type) {
            case AntiAddictRet.TYPE_TIPS:
            case AntiAddictRet.TYPE_LOGOUT:
                if (!mAntiAddictExecuteState) {
                    mAntiAddictExecuteState = true;
                    AlertDialog.Builder builder = new AlertDialog.Builder(mainActivity);
                    builder.setTitle(ret.title);
                    builder.setMessage(ret.content);
                    builder.setPositiveButton("知道了",
                            new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog,
                                                    int whichButton) {
                                    if (modal == 1) {
                                        // 根据modal字段来判断是否需要强制用户下线
                                        // 强制用户下线
                                        userLogout();
                                    }
                                    changeExecuteState(false);
                                }
                            });
                    builder.setCancelable(false);
                    builder.show();
                    // 已执行指令
                    YSDKApi.reportAntiAddictExecute(ret, System.currentTimeMillis());
                }

                break;

            case AntiAddictRet.TYPE_OPEN_URL:
                if (!mAntiAddictExecuteState) {
                    mAntiAddictExecuteState = true;
                    View popwindowView = View.inflate(mainActivity, R.layout.com_tencent_ysdk_msgbox_popwindow_view, null);
                    WebView webView = popwindowView.findViewById(R.id.com_tencent_ysdk_real_name_webview_dialog_webview);
                    Button closeButton = popwindowView.findViewById(R.id.com_tencent_ysdk_real_name_webview_dialog_close);

                    WebSettings settings= webView.getSettings();
                    settings.setJavaScriptEnabled(true);
                    webView.setWebViewClient(new WebViewClient());
                    webView.loadUrl(ret.url);

                    final PopupWindow popupWindow = new PopupWindow(popwindowView, 1000, 1000);
                    popupWindow.setTouchable(true);
                    popupWindow.setOutsideTouchable(false);
                    popupWindow.setBackgroundDrawable(new BitmapDrawable());

                    closeButton.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            if (modal == 1) {
                                userLogout();
                            }
                            popupWindow.dismiss();
                            changeExecuteState(false);
                        }
                    });

                    popupWindow.showAtLocation(popwindowView, Gravity.CENTER, 0, 0);
                    // 已执行指令
                    YSDKApi.reportAntiAddictExecute(ret, System.currentTimeMillis());
                }

                break;

        }
    }
    private static void changeExecuteState(boolean state) {
        mAntiAddictExecuteState = state;
    }
    //退出方法
    public static void userLogout() {
        YSDKApi.logout();
//        sShowView.hideModule();
//        sShowView.resetMainView();

    }
}