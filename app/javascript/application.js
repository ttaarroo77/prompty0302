// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Bootstrap
import "bootstrap"
import "@popperjs/core"

// イベントハンドラの設定
document.addEventListener('DOMContentLoaded', function () {
  // すべてのフォームに対してCSRFトークンの更新処理を追加
  document.querySelectorAll('form').forEach(function (form) {
    form.addEventListener('submit', function () {
      const metaTag = document.querySelector('meta[name="csrf-token"]');
      if (metaTag) {
        const token = metaTag.content;
        const input = form.querySelector('input[name="authenticity_token"]');
        if (input) input.value = token;
      }
    });
  });

  // タグ生成ボタンのイベントハンドラ
  const tagGenerateBtn = document.querySelector('form[action*="generate_tags"]');
  if (tagGenerateBtn) {
    tagGenerateBtn.addEventListener('submit', function (e) {
      e.preventDefault();
      fetch(this.action, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        credentials: 'same-origin'
      })
        .then(response => {
          if (response.ok) {
            window.location.reload();
          } else {
            console.error('タグ生成に失敗しました');
          }
        })
        .catch(error => {
          console.error('エラー:', error);
        });
    });
  }

  // プロンプト削除ボタンのイベントハンドラ（コメントアウト）
  /*
  const deletePromptBtn = document.querySelector('form[action*="/prompts/"][method="post"] input[name="_method"][value="delete"]');
  if (deletePromptBtn) {
    const form = deletePromptBtn.closest('form');
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      if (confirm('このプロンプトを削除してもよろしいですか？')) {
        fetch(this.action, {
          method: 'DELETE',
          headers: {
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
            'Content-Type': 'application/json'
          },
          credentials: 'same-origin'
        })
          .then(response => {
            if (response.ok) {
              window.location.href = '/';
            } else {
              console.error('削除に失敗しました');
            }
          })
          .catch(error => {
            console.error('エラー:', error);
          });
      }
    });
  }
  */

  // タグ削除ボタンのイベントハンドラ
  document.querySelectorAll('form[id^="delete-tag-"]').forEach(function (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();

      const url = this.getAttribute('action');
      console.log('タグを削除: ' + url);

      fetch(url, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        credentials: 'same-origin'
      })
        .then(response => {
          if (response.ok) {
            window.location.reload();
          } else {
            console.error('タグの削除に失敗しました');
          }
        })
        .catch(error => {
          console.error('エラー:', error);
        });
    });
  });

  // タグ追加フォームのイベントハンドラ
  const tagAddForm = document.querySelector('form[action*="/tags"][method="post"]');
  if (tagAddForm) {
    tagAddForm.addEventListener('submit', function (e) {
      e.preventDefault();
      const formData = new FormData(this);

      fetch(this.action, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        },
        body: formData,
        credentials: 'same-origin'
      })
        .then(response => {
          if (response.ok) {
            window.location.reload();
          } else {
            console.error('タグの追加に失敗しました');
          }
        })
        .catch(error => {
          console.error('エラー:', error);
        });
    });
  }
});
