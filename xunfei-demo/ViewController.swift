//
//  ViewController.swift
//  xunfei-demo
//
//  Created by umi on 2020/8/12.
//  Copyright © 2020 com. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    //不带界面的识别对象
    lazy var iFlySpeechRecognizer: IFlySpeechRecognizer = {
        let iFlySpeechRecognizer = IFlySpeechRecognizer.sharedInstance()!
        //设置识别参数
        //设置为听写模式
        iFlySpeechRecognizer.setParameter("iat", forKey: IFlySpeechConstant.ifly_DOMAIN())
        //asr_audio_path 是录音文件名，设置 value 为 nil 或者为空取消保存，默认保存目录在 Library/cache 下。
        iFlySpeechRecognizer.setParameter("iat.pcm", forKey: IFlySpeechConstant.asr_AUDIO_PATH())
        //设置最长录音时间:60秒
        iFlySpeechRecognizer.setParameter("-1", forKey: IFlySpeechConstant.speech_TIMEOUT())
        //设置语音后端点:后端点静音检测时间，即用户停止说话多长时间内即认为不再输入， 自动停止录音
        iFlySpeechRecognizer.setParameter("10000", forKey: IFlySpeechConstant.vad_EOS())
        //设置语音前端点:静音超时时间，即用户多长时间不说话则当做超时处理
        iFlySpeechRecognizer.setParameter("5000", forKey: IFlySpeechConstant.vad_BOS())
        //网络等待时间
        iFlySpeechRecognizer.setParameter("2000", forKey: IFlySpeechConstant.net_TIMEOUT())
        //设置采样率，推荐使用16K
        iFlySpeechRecognizer.setParameter("16000", forKey: IFlySpeechConstant.sample_RATE())
        //设置语言
        iFlySpeechRecognizer.setParameter("en_us", forKey: IFlySpeechConstant.language())
        //设置方言
        iFlySpeechRecognizer.setParameter("mandarin", forKey: IFlySpeechConstant.accent())
        //设置是否返回标点符号
        iFlySpeechRecognizer.setParameter("0", forKey: IFlySpeechConstant.asr_PTT())
        //设置代理
        iFlySpeechRecognizer.delegate = self

        return iFlySpeechRecognizer
    }()
    ///生成的字符
    private var resultStringFromJson: String?
    ///当前是否可以进行录音
    private var isStartRecord = true
    ///是否已经开始播放
    private var ishadStart = false
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
       
        let btnRect = CGRect(x: 100 * 0.5, y: 200, width: 100, height: 100)
        let btn = UIButton(frame: btnRect)
        btn.backgroundColor = UIColor.orange
        btn.setTitle("语音识别", for: .normal)
        view.addSubview(btn)

        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(fromLongPressBtn:)))
        longpress.minimumPressDuration = 0.1
        btn.addGestureRecognizer(longpress)
    }
    
    @objc func longPressAction(fromLongPressBtn longPress: UILongPressGestureRecognizer?) {
        print("AIAction")
        let currentPoint = longPress?.location(in: longPress?.view)

        if isStartRecord {
            resultStringFromJson = ""
            //启动识别服务
            iFlySpeechRecognizer.startListening()
            isStartRecord = false
            ishadStart = true
            //开始声音动画
            //[self TipsViewShowWithType:@"start"];
        }
        //如果上移的距离大于60,就提示放弃本次录音
        if (currentPoint?.y ?? 0.0) < -60 {
            //变成取消发送图片
            //        [self TipsViewShowWithType:@"cancel"];
            ishadStart = false
        } else {
            if !ishadStart {
                ishadStart = true
            }
        }
        if longPress?.state == .ended {
            isStartRecord = true
            if (currentPoint?.y ?? 0.0) < -60 {
                iFlySpeechRecognizer.cancel()
            } else {
                iFlySpeechRecognizer.stopListening()
            }
          
        }

    }

}


extension ViewController: IFlySpeechRecognizerDelegate {
    func onCompleted(_ errorCode: IFlySpeechError!) {
        print("completed")
    }
    
    func onResults(_ results: [Any]!, isLast: Bool) {
        var resultString = ""
        let dic = results[0] as! [String:Any]
        for key in dic {
            resultString += "\(key)"
        }
        print(resultString)
    }
    func onEndOfSpeech() {
        isStartRecord = true
    }
    func onBeginOfSpeech() {
        print("begin")
    }
    func onCancel() {
        print("cancel")
    }
}
    

