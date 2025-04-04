require 'rails_helper'

RSpec.describe "プロンプト詳細画面の文字数制限", type: :system do
  let(:user) { create(:user) }
  let(:prompt) { create(:prompt, user: user) }

  before do
    sign_in user
  end

  describe "タイトル入力" do
    context "100文字以下のタイトル" do
      let(:valid_title) { "a" * 100 }

      it "タイトルが正常に保存されること" do
        visit edit_prompt_path(prompt)
        fill_in "prompt_title", with: valid_title
        click_button "更新"
        expect(page).to have_content("プロンプトを更新しました")
        expect(prompt.reload.title).to eq valid_title
      end
    end

    context "100文字を超えるタイトル" do
      let(:invalid_title) { "a" * 101 }

      it "エラーメッセージが表示されること" do
        visit edit_prompt_path(prompt)
        fill_in "prompt_title", with: invalid_title
        click_button "更新"
        expect(page).to have_content("タイトルは100文字以内で入力してください")
      end
    end
  end

  describe "説明文入力" do
    context "500文字以下の説明文" do
      let(:valid_description) { "a" * 500 }

      it "説明文が正常に保存されること" do
        visit edit_prompt_path(prompt)
        fill_in "prompt_description", with: valid_description
        click_button "更新"
        expect(page).to have_content("プロンプトを更新しました")
        expect(prompt.reload.description).to eq valid_description
      end
    end

    context "500文字を超える説明文" do
      let(:invalid_description) { "a" * 501 }

      it "エラーメッセージが表示されること" do
        visit edit_prompt_path(prompt)
        fill_in "prompt_description", with: invalid_description
        click_button "更新"
        expect(page).to have_content("説明は500文字以内で入力してください")
      end
    end
  end

  describe "プロンプト本文入力" do
    context "2000文字以下の本文" do
      let(:valid_content) { "a" * 2000 }

      it "本文が正常に保存されること" do
        visit edit_prompt_path(prompt)
        fill_in "prompt_content", with: valid_content
        click_button "更新"
        expect(page).to have_content("プロンプトを更新しました")
        expect(prompt.reload.content).to eq valid_content
      end
    end

    context "2000文字を超える本文" do
      let(:invalid_content) { "a" * 2001 }

      it "エラーメッセージが表示されること" do
        visit edit_prompt_path(prompt)
        fill_in "prompt_content", with: invalid_content
        click_button "更新"
        expect(page).to have_content("コンテンツは2000文字以内で入力してください")
      end
    end
  end

  describe "メモ入力" do
    context "1000文字以下のメモ" do
      let(:valid_notes) { "a" * 1000 }

      it "メモが正常に保存されること" do
        visit edit_prompt_path(prompt)
        fill_in "prompt_notes", with: valid_notes
        click_button "更新"
        expect(page).to have_content("プロンプトを更新しました")
        expect(prompt.reload.notes).to eq valid_notes
      end
    end

    context "1000文字を超えるメモ" do
      let(:invalid_notes) { "a" * 1001 }

      it "エラーメッセージが表示されること" do
        visit edit_prompt_path(prompt)
        fill_in "prompt_notes", with: invalid_notes
        click_button "更新"
        expect(page).to have_content("メモは1000文字以内で入力してください")
      end
    end
  end
end