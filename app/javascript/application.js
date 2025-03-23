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

  // 既存タグ一覧のタグクリック処理 (検索用)
  document.querySelectorAll('.tag-item').forEach(function (tagLink) {
    tagLink.addEventListener('click', function () {
      console.log('Tag clicked for search:', this.textContent.trim());
    });
  });

  // タグ検索のフィルタリング機能
  const searchInput = document.getElementById('tagSearch');
  if (searchInput) {
    const tagItems = document.querySelectorAll('.tag-item');

    searchInput.addEventListener('input', function () {
      const searchValue = this.value.toLowerCase();

      tagItems.forEach(function (item) {
        const tagName = item.textContent.toLowerCase();
        if (tagName.includes(searchValue)) {
          item.style.display = 'inline-block';
        } else {
          item.style.display = 'none';
        }
      });
    });
  }

  // コンソールにデバッグ情報を出力
  console.log('Event listeners initialized');
  console.log('Delete form found:', !!document.querySelector('form[action$="/destroy"]'));
  console.log('Suggested tag buttons:', document.querySelectorAll('.suggested-tag-btn').length);
  console.log('Tag items for search:', document.querySelectorAll('.tag-item').length);
}
