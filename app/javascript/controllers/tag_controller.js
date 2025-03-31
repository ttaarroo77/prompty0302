import { Controller } from "@hotwired/stimulus"

// タグ操作のためのStimulusコントローラー
// 現在は使用していないが、将来的に拡張する可能性があるため維持
export default class extends Controller {
  connect() {
    console.log("Tag controller connected")
  }
} 