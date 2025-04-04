require 'rails_helper'

RSpec.describe "タグの文字数制限", type: :system do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "タグ名入力" do
    context "30文字以下のタグ名" do
      let(:valid_tag_name) { "a" * 30 }

      it "タグが正常に作成されること" do
        visit new_tag_path
        fill_in "tag_name", with: valid_tag_name
        click_button "作成"
        expect(page).to have_content("タグを作成しました")
        expect(Tag.last.name).to eq valid_tag_name
      end
    end

    context "30文字を超えるタグ名" do
      let(:invalid_tag_name) { "a" * 31 }

      it "エラーメッセージが表示されること" do
        visit new_tag_path
        fill_in "tag_name", with: invalid_tag_name
        click_button "作成"
        expect(page).to have_content("タグ名は30文字以内で入力してください")
      end
    end
  end

  describe "タグの説明入力" do
    context "200文字以下の説明" do
      let(:valid_description) { "a" * 200 }

      it "説明が正常に保存されること" do
        visit new_tag_path
        fill_in "tag_name", with: "テストタグ"
        fill_in "tag_description", with: valid_description
        click_button "作成"
        expect(page).to have_content("タグを作成しました")
        expect(Tag.last.description).to eq valid_description
      end
    end

    context "200文字を超える説明" do
      let(:invalid_description) { "a" * 201 }

      it "エラーメッセージが表示されること" do
        visit new_tag_path
        fill_in "tag_name", with: "テストタグ"
        fill_in "tag_description", with: invalid_description
        click_button "作成"
        expect(page).to have_content("説明は200文字以内で入力してください")
      end
    end
  end
end