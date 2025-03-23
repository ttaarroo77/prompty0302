// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

document.addEventListener('turbo:load', function () {
  console.log('Turbo:load fired!');
  initializeEventListeners();

  // Bootstrap tooltips initialization
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl);
  });
});

// DOMContentLoaded for the first page load
document.addEventListener('DOMContentLoaded', function () {
  console.log('DOMContentLoaded fired!');
  initializeEventListeners();
});

// Add event listener for Turbo events
document.addEventListener('turbo:render', function () {
  console.log('Turbo:render fired!');
  initializeEventListeners();
});

document.addEventListener('turbo:frame-render', function (event) {
  console.log('Turbo frame rendered:', event.target.id);
  initializeEventListeners();
});

function initializeEventListeners() {
  // Delete confirmation for prompts
  const deleteForm = document.querySelector('form[action$="/destroy"]');
  if (deleteForm) {
    deleteForm.addEventListener('submit', function (e) {
      if (!confirm('本当に削除しますか？')) {
        e.preventDefault();
      }
    });
  }

  // タグ提案ボタンクリック処理
  document.querySelectorAll('.suggested-tag-btn').forEach(function (btn) {
    console.log('Added click listener to tag button:', btn.textContent.trim());
    btn.addEventListener('click', function () {
      const tagName = this.dataset.tagName;
      const tagInput = document.querySelector('input[name="tag[name]"]');

      if (tagInput) {
        tagInput.value = tagName;
        console.log('Set tag input value to:', tagName);
        // タグを追加用フォームを自動的に送信
        const tagForm = document.querySelector('form.new_tag');
        if (tagForm) {
          console.log('Submitting tag form');
          tagForm.submit();
        }
      }
    });
  });

  // コンソールにデバッグ情報を出力
  console.log('Event listeners initialized');
  console.log('Delete form found:', !!document.querySelector('form[action$="/destroy"]'));
  console.log('Suggested tag buttons:', document.querySelectorAll('.suggested-tag-btn').length);
}
