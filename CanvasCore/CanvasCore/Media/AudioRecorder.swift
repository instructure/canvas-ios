//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation
import AVFoundation

protocol AudioRecorderDelegate: class {
    func recorder(_ recorder: AudioRecorder, didFinishRecordingWithError error: NSError?)
    func recorder(_ recorder: AudioRecorder, progressWithTime time: TimeInterval, meter: Int)
}

/** records an audio file and stores it at `recordedFileURL`

    note: `AudioRecorder` instances will not delete their audio files
    it's clients are expected to clean up the recorded files.
 */
class AudioRecorder: NSObject {
    fileprivate let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy HH.mm.ss"
        return df
        }()
    
    fileprivate let meterTable: MeterTable
    var recordedFileURL: URL?
    
    weak var delegate: AudioRecorderDelegate?
    
    fileprivate var timer: CADisplayLink? = nil
    
    init(ticks: Int) {
        meterTable = MeterTable(meterTicks: ticks)
    }
    
    deinit {
        stopRecording()
    }
    
    var recorder: AVAudioRecorder?
    
    func startRecording() throws {
        let now = Date()
        
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
        let recordedFileURL = tmp.appendingPathComponent(dateFormatter.string(from: now)).appendingPathExtension("m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
            AVSampleRateKey: 22050,
            AVNumberOfChannelsKey: 2,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false
        ]
        
        recorder = try AVAudioRecorder(url: recordedFileURL, settings: settings)
        recorder?.delegate = self
        recorder?.isMeteringEnabled = true

        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord)
        try AVAudioSession.sharedInstance().setActive(true)
        
        let began = recorder?.record() ?? false
        
        if began {
            timer = CADisplayLink(target: self, selector: #selector(AudioRecorder.timerFired(_:)))
            timer?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
            delegate?.recorder(self, progressWithTime: 0, meter: 0)
            self.recordedFileURL = recordedFileURL
        } else {
            do { try FileManager.default.removeItem(at: recordedFileURL) } catch {}
        }
    }
    
    func stopRecording() {
        timer?.invalidate()
        timer = nil
        recorder?.delegate = nil
        recorder?.stop()
        recorder = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch let e {
            print("erro stopping the recording session \(e)")
        }
    }
}


extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        stopRecording()
        delegate?.recorder(self, didFinishRecordingWithError: nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        stopRecording()
        delegate?.recorder(self, didFinishRecordingWithError: error as NSError?)
    }
}

extension AudioRecorder {
    func timerFired(_ timer: CADisplayLink) {
        if let r = recorder, r.isRecording {
            r.updateMeters()
            let peak0 = r.averagePower(forChannel: 0)
            let peak1 = r.averagePower(forChannel: 1)
            
            let avgPeak = (peak0 + peak1) / 2.0
            
            let meter:Int = meterTable[Double(avgPeak)]
            
            delegate?.recorder(self, progressWithTime: r.currentTime, meter: meter)
        }
    }
}
