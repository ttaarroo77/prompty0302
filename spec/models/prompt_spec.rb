require 'rails_helper'

RSpec.describe Prompt, type: :model do
  let(:user) { create(:user) }
  let(:prompt) { build(:prompt, user: user) }

  describe "文字数制限" do
    context "タイトル" do
      it "100文字以下のタイトルは有効" do
        prompt.title = "a" * 100
        expect(prompt).to be_valid
      end

      it "100文字を超えるタイトルは無効" do
        prompt.title = "a" * 101
        expect(prompt).not_to be_valid
        expect(prompt.errors[:title]).to include("は100文字以内で入力してください")
      end
    end

    context "説明文" do
      it "500文字以下の説明文は有効" do
        prompt.description = "a" * 500
        expect(prompt).to be_valid
      end

      it "500文字を超える説明文は無効" do
        prompt.description = "a" * 501
        expect(prompt).not_to be_valid
        expect(prompt.errors[:description]).to include("は500文字以内で入力してください")
      end
    end

    # context "プロンプト本文" do
    #   it "2000文字以下の本文は有効" do
    #     prompt.content = "a" * 2000
    #     expect(prompt).to be_valid
    #   end

    #   it "2000文字を超える本文は無効" do
    #     prompt.content = "a" * 2001
    #     expect(prompt).not_to be_valid
    #     expect(prompt.errors[:content]).to include("は2000文字以内で入力してください")
    #   end
    # end

    # context "メモ" do
    #   it "1000文字以下のメモは有効" do
    #     prompt.notes = "a" * 1000
    #     expect(prompt).to be_valid
    #   end

    #   it "1000文字を超えるメモは無効" do
    #     prompt.notes = "a" * 1001
    #     expect(prompt).not_to be_valid
    #     expect(prompt.errors[:notes]).to include("は1000文字以内で入力してください")
    #   end
    # end
  end

  describe 'バリデーション' do
    it 'タイトルが15文字を超える場合は無効' do
      prompt = build(:prompt, title: 'a' * 16, user: user)
      expect(prompt).not_to be_valid
      expect(prompt.errors[:title]).to include('は15文字以内で入力してください')
    end

    it 'タイトルが15文字以内の場合は有効' do
      prompt = build(:prompt, title: 'a' * 15, user: user)
      expect(prompt).to be_valid
    end

    it 'タグ名が21文字を超える場合は無効' do
      prompt = create(:prompt, user: user)
      tag = build(:tag, name: 'a' * 22, user: user, prompt: prompt)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include('は21文字以内で入力してください')
    end
  end
end 