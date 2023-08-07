# EditText



## 焦点变化

```kotlin
var focusChangeListener = View.OnFocusChangeListener {
    v, hasFocus -> isInput = hasFocus
}

editText.onFocusChangeListener = focusChangeListener
```

文本框重新获取焦点方法：
```java
editText.setFocusable(true);
editText.setFocusableInTouchMode(true);
editText.requestFocus();

editText.clearFocus();//失去焦点
editText.requestFocus();//获取焦点
```

## 内容变化

```kotlin
val searchChangeListener = object: TextWatcher {
        override fun afterTextChanged(s: Editable?) {

        }

        override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

        }

        override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            s?.let {
                binding.clearSearchIv.visibility = if (it.isNotEmpty()) View.VISIBLE else View.GONE
            }
        }

    }


editText.addTextChangedListener(searchChangeListener)
```


### 显示长度和长度限制

```
<com.google.android.material.textfield.TextInputLayout
    android:id="@+id/reason_desc_container"
    style="@style/Widget.MaterialComponents.TextInputLayout.OutlinedBox"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    app:counterEnabled="true"
    app:counterMaxLength="400"
    android:visibility="gone">
    <com.google.android.material.textfield.TextInputEditText
        android:id="@+id/reason_desc"
        android:textSize="14sp"
        android:textColor="@color/textColorSecondary"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:minHeight="150dp"
        android:gravity="top"
        android:paddingStart="16dp"
        android:paddingEnd="16dp"
        android:paddingTop="8dp"
        android:paddingBottom="8dp"
        android:background="@drawable/bg_report_other_edit"
        tools:text="Other"
        android:maxLength="400"
        android:cursorVisible="true"
        android:textCursorDrawable="@null"
        android:text="@={viewModel.reasonDesc}"/>
</com.google.android.material.textfield.TextInputLayout>
```